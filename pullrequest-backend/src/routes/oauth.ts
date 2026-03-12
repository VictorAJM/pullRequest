import { Elysia, t } from 'elysia';
import { db } from '@services/database';

export const oauthRoute = new Elysia({ prefix: 'oauth' })
  .post('register_token', ({ headers, body }) => {
    const { platform, oauth_token, refresh_token, expires_in } = body;

    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    db.prepare(`
      UPDATE users
      SET
        ${platform === 'ytm' ?
        `ytm_oauth_token = $oauthToken,
        ytm_refresh_token = $refreshToken,
        ytm_expires_at = $expiresAt` :
        `spotify_oauth_token = $oauthToken,
        spotify_refresh_token = $refreshToken,
        spotify_expires_at = $expiresAt`}
      WHERE device_id = $deviceId
    `).run({
          $oauthToken: oauth_token,
          $refreshToken: refresh_token,
          $expiresAt: Date.now() + (expires_in - 60) * 1000,
          $deviceId: deviceId
        });

    return {
      success: true,
      message: "Tokens saved"
    };
  }, {
    body: t.Object({
      platform: t.Union([
        t.Literal('ytm'),
        t.Literal('spotify')
      ]),
      oauth_token: t.String(),
      refresh_token: t.String(),
      expires_in: t.Number()
    })
  });