import { SpotifyApi } from "@spotify/web-api-ts-sdk";
import { getOauthTokens, saveAccessTokens } from './database';
import { AuthData, SpotifyPlaylistItemsSchema, PlaylistItems } from "@lib/custom_types";

async function refreshAuthToken(refreshToken: string): Promise<AuthData> {
  const clientId = process.env.SPOTIFY_CLIENT_ID;
  const clientSecret = process.env.SPOTIFY_SECRET;

  if (!clientId || !clientSecret)
    throw new Error("Failed to load Spotify client credentials");

  const authHeader = Buffer.from(`${clientId}:${clientSecret}`)
    .toString('base64');

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
    console.log(await response.text());
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

    saveAccessTokens(
      deviceId,
      'spotify',
      newTokens
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

export async function getAccessTokenFromCode(code: string): Promise<AuthData | null> {
  const redirectUri = process.env.SPOTIFY_REDIRECT_URI;
  const clientId = process.env.SPOTIFY_CLIENT_ID;
  const clientSecret = process.env.SPOTIFY_SECRET;

  if (!redirectUri || !clientId || !clientSecret) return null;

  const authHeader = Buffer.from(`${clientId}:${clientSecret}`)
    .toString('base64');

  const response = await fetch('https://accounts.spotify.com/api/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${authHeader}`
    },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: redirectUri
    })
  });

  if (!response.ok) return null;

  const data = await response.json();

  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token,
    expiresAt: Date.now() + (data.expires_in - 60) * 1000
  };
}

export async function getPlaylistItems(
  playlistId: string,
  deviceId: string,
  limit: number,
  offset: number
): Promise<PlaylistItems | null> {
  const tokens = getOauthTokens(deviceId, 'spotify');

  const result = getOauthTokens(deviceId, 'spotify');
  if (!result) return null;

  let { oauth_token, refresh_token, expires_at } = result;

  if (result.expires_at - Date.now() < 30 * 1000) {
    const newTokens = await refreshAuthToken(result.refresh_token);

    saveAccessTokens(
      deviceId,
      'spotify',
      newTokens
    );

    oauth_token = newTokens.accessToken;
    refresh_token = newTokens.refreshToken;
    expires_at = newTokens.expiresAt;
  }

  const res = await fetch(
    `https://api.spotify.com/v1/playlists/${playlistId}/items?limit=${limit}&offset=${offset}`,
    { headers: { Authorization: `Bearer ${oauth_token}` } }
  );
  if (!res.ok) throw new Error(`Spotify error: ${res.status}`);
  const data = await res.json();

  const filteredData = SpotifyPlaylistItemsSchema.parse(data);

  return {
    items: filteredData.items.map(item => ({
      platform: 'spotify',
      id: item.item.id,
      title: item.item.name,
      artist: item.item.artists[0].name,
      thumbnail: item.item.album.images[0]
    })),
    next: (offset + limit < filteredData.total)
  };
}