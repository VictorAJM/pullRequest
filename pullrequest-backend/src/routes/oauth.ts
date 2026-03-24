import { Elysia, t } from 'elysia';
import { saveAccessTokens, getOauthTokens } from '@services/database';
import { getAccessTokenFromCode as getSpotifyAccessTokenFromCode } from '@services/spotify_api_client';
import { getAccessTokenFromCode as getYoutubeAccessTokenFromCode } from '@services/youtube_api_client';

export const oauthRoute = new Elysia({ prefix: 'oauth' })
  .post('register_token', ({ headers, body }) => {
    const { platform, oauth_token, refresh_token, expires_in } = body;

    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    saveAccessTokens(
      deviceId,
      platform,
      {
        accessToken: oauth_token,
        refreshToken: refresh_token,
        expiresAt: Date.now() + (expires_in - 60) * 1000
      }
    );

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
  }).post('register_code', async ({ headers, body, status }) => {
    const { platform, code } = body;

    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    if (platform === 'ytm') {
      const authData = await getYoutubeAccessTokenFromCode(code);
      if (!authData) {
        console.log('Oh fucky :(');
        return status(500, "Failed to exange Youtube code.");
      }

      saveAccessTokens(deviceId, 'ytm', authData);
    } else {
      const authData = await getSpotifyAccessTokenFromCode(code);
      if (!authData) {
        return status(500, "Failed to exange Spotify code.");
      }

      saveAccessTokens(deviceId, 'spotify', authData);
    }

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
      code: t.String(),
    })
  }).get('status', ({ headers, body }) => {
    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    const ytmTokens = getOauthTokens(deviceId, 'ytm');
    const spotifyTokens = getOauthTokens(deviceId, 'spotify');

    return {
      ytm: ytmTokens !== null,
      spotify: spotifyTokens !== null
    };
  });