import { Elysia, t } from 'elysia';
import { EventEmitter } from 'events';
import { transferUpdateMessage } from '@lib/custom_types';

const activeTransfers = new Map<string, transferUpdateMessage>();
const sseBus = new EventEmitter();

export const playlistTransferRoutes = new Elysia({ prefix: '/transfer' })
  .post('/start', ({ body, headers, set }) => {
    const { platform_from, playlist_id } = body;

    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    if (activeTransfers.has(deviceId)) {
      set.status = 409;
      return { error: 'This device already has an ongoing transfer.' };
    }

    const worker = new Worker('./src/services/transferWorker.ts');
    worker.onmessage = (event) => {
      const { status } = event.data;

      console.log(event.data);

      if (status === 'completed' || status === 'error') {
        worker.terminate();
        activeTransfers.delete(deviceId);
      } else {
        activeTransfers.set(deviceId, event.data);
      }

      sseBus.emit(`update:${deviceId}`, event.data);
    }

    worker.postMessage({
      deviceId,
      playlistId: playlist_id,
      platformFrom: platform_from
    });
    return { success: true, message: 'Transfer started' };

  }, {
    body: t.Object({
      platform_from: t.Union([
        t.Literal('ytm'),
        t.Literal('spotify')
      ]),
      playlist_id: t.String()
    })
  })
  .get('updates', async function* ({ headers, set }) {
    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    if (!activeTransfers.has(deviceId)) {
      set.status = 404;
      return { error: 'No active transfers for this device.' }
    }

    set.headers['Content-Type'] = 'text/event-stream';
    set.headers['Cache-Control'] = 'no-cache';
    set.headers['Connection'] = 'keep-alive';

    const lastState = activeTransfers.get(deviceId);
    yield `data: ${JSON.stringify({ ...lastState, type: 'sync' })}\n\n`;

    try {
      while (activeTransfers.has(deviceId)) {
        const nextEvent = await new Promise((resolve) => {
          const listener = (data: any) => {
            clearInterval(checkInterval);
            resolve(data);
          };

          sseBus.once(`update:${deviceId}`, resolve);

          const checkInterval = setInterval(() => {
            if (!activeTransfers.has(deviceId)) {
              clearInterval(checkInterval);
              sseBus.off(`update:${deviceId}`, listener);
              resolve(null);
            }
          }, 500);
        });

        if (!nextEvent) break;

        yield `data: ${JSON.stringify(nextEvent)}\n\n`;;

        if (
          (nextEvent as transferUpdateMessage).status === 'completed' ||
          (nextEvent as transferUpdateMessage).status === 'error'
        ) {
          break;
        }
      }
    } finally {
      console.log(`Connection closed for ${deviceId}`);
    }
  });