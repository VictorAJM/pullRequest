import { Elysia, t } from 'elysia';
import { db } from '@services/database'

export const registerRoute = new Elysia().post('/register', ({ body }) => {
  const { public_key } = body;

  const new_device_id = crypto.randomUUID()

  db.prepare(`
      INSERT INTO users (device_id, public_key) 
      VALUES ($deviceId, $publicKey)
      ON CONFLICT(device_id) DO UPDATE SET public_key = $publicKey
    `).run({
    $deviceId: new_device_id,
    $publicKey: public_key
  });

  console.log("New device registered:", new_device_id);

  return { device_id: new_device_id };
}, {
  body: t.Object({
    public_key: t.String()
  })
});
