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

    activeTransfers.set(deviceId, {
      status: 'in_progress',
      current_song: '',
      totalItems: 0,
      currentItem: 0,
    });

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
    yield `data: ${JSON.stringify(lastState)}\n\n`;

    const queue: any[] = [];
    let resolveQueue: (() => void) | null = null;
    let isFinished = false;

    const listener = (data: any) => {
      queue.push(data);
      if (resolveQueue) {
        resolveQueue();
        resolveQueue = null;
      }
      if (data.status === 'completed' || data.status === 'error') {
        isFinished = true;
      }
    };

    sseBus.on(`update:${deviceId}`, listener);

    try {
      while (true) {
        if (queue.length === 0 && !isFinished && activeTransfers.has(deviceId)) {
          await Promise.race([
            new Promise<void>((resolve) => { resolveQueue = resolve; }),
            new Promise<void>((resolve) => setTimeout(resolve, 1000))
          ]);
        }

        while (queue.length > 0) {
          const nextEvent = queue.shift();
          yield `data: ${JSON.stringify(nextEvent)}\n\n`;
          if (nextEvent.status === 'completed' || nextEvent.status === 'error') {
            return;
          }
        }

        if (isFinished || !activeTransfers.has(deviceId)) {
          break;
        }
      }
    } finally {
      sseBus.off(`update:${deviceId}`, listener);
      console.log(`Connection closed for ${deviceId}`);
    }
  });