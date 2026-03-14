import { SpotifyApi } from "@spotify/web-api-ts-sdk";
import { getOauthTokens, saveOauthTokens } from './database';

async function refreshAuthToken(refreshToken: string) {
  const authHeader = Buffer.from(
    `{${process.env.SPOTIFY_CLIENT_ID}:${process.env.SPOTIFY_SECRET}}`
  ).toString('base64');

  const response = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": `Basic ${authHeader}`
    },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: refreshToken
    })
  });

  if (!response.ok) {
    throw new Error("Failed to refresh Spotify token");
  }

  const data = await response.json();

  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token || refreshToken,
    expiresAt: Date.now() + (data.expires_in * 1000)
  };
}

export async function createSpotifyClient(deviceId: string):
  Promise<SpotifyApi | null> {
  const result = getOauthTokens(deviceId, 'spotify');
  if (!result) return null;

  let { oauth_token, refresh_token, expires_at } = result;

  if (result.expires_at - Date.now() < 30 * 1000) {
    const newTokens = await refreshAuthToken(result.refresh_token);

    saveOauthTokens(
      deviceId,
      'spotify',
      newTokens.accessToken,
      newTokens.refreshToken,
      newTokens.expiresAt
    );

    oauth_token = newTokens.accessToken;
    refresh_token = newTokens.refreshToken;
    expires_at = newTokens.expiresAt;
  }

  return SpotifyApi.withAccessToken(process.env.SPOTIFY_CLIENT_ID!, {
    access_token: oauth_token,
    refresh_token,
    token_type: "Bearer",
    expires_in: Math.floor((expires_at - Date.now()) / 1000),
  });
}