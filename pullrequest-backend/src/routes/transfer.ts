import { Elysia, t } from 'elysia';

export const playlistTransferRoutes = new Elysia()
  .post('/transfer', ({ body, headers }) => {
    const { platform_from, playlist_id } = body;

    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    const worker = new Worker('./src/services/transferWorker.ts');
    worker.onmessage = (event) => {
      const { status } = event.data;

      console.log(event.data);

      if (status === 'completed')
        worker.terminate();
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
  });