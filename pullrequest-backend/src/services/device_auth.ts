import { Elysia } from 'elysia';
import { db } from '@services/database';
import crypto from 'node:crypto';

export const deviceAuthPlugin = new Elysia({ name: 'device-auth' })
  .onBeforeHandle({ as: 'scoped' }, ({ headers, status }) => {
    const deviceId = headers['x-device-id'];
    const signed_timestamp = headers['x-signed-timestamp'];
    const raw_timestamp = headers['x-timestamp'];

    if (!deviceId || !signed_timestamp || !raw_timestamp) {
      return status(401, 'Invalid or missing signed timestamp');
    }

    if (Math.abs(Date.now() - Number(raw_timestamp)) > 5000) {
      return status(401, 'Timestamp is too old (> 5 seconds)');
    }

    const result = db.prepare(`
          SELECT public_key
          FROM users 
          WHERE device_id = $deviceId
        `).get({
      $deviceId: deviceId
    }) as { public_key: string } | null;

    if (!result) {
      return status(401, 'Device not found');
    }

    const public_key = result.public_key;
    const verifier = crypto.createVerify('sha256');
    verifier.update(raw_timestamp);

    if (!verifier.verify(public_key, signed_timestamp, 'base64')) {
      return status(401, 'Invalid signed timestamp');
    }
  });