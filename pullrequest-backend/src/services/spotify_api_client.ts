import { SpotifyApi } from "@spotify/web-api-ts-sdk";
import { getOauthTokens, saveAccessTokens } from './database';
import { AuthData, SpotifyPlaylistItemsSchema, PlaylistItems, PlaylistItem, Playlist } from "@lib/custom_types";

async function refreshAuthToken(refreshToken: string): Promise<AuthData> {
  const clientId = process.env.SPOTIFY_CLIENT_ID;
  const clientSecret = process.env.SPOTIFY_SECRET;

  if (!clientId || !clientSecret)
    throw new Error("Failed to load Spotify client credentials");

  const authHeader = Buffer.from(`${clientId}:${clientSecret}`)
    .toString('base64');

  console.log('[spotify/refresh] Refreshing access token...');

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
    const body = await response.text();
    console.error(`[spotify/refresh] Failed (${response.status}):`, body);
    throw new Error("Failed to refresh Spotify token");
  }

  const data = await response.json();
  console.log('[spotify/refresh] Token refreshed successfully');

  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token || refreshToken,
    expiresAt: Date.now() + (data.expires_in * 1000)
  };
}

async function getAccessToken(deviceId: string): Promise<AuthData> {
  console.log(`[spotify/token] Getting access token for device ${deviceId}`);
  const tokens = getOauthTokens(deviceId, 'spotify');
  if (!tokens)
    throw new Error("Failed to authenticate with Spotify API");

  const timeLeft = tokens.expires_at - Date.now();
  console.log(`[spotify/token] Token expires in ${Math.round(timeLeft / 1000)}s`);

  if (timeLeft < 90) {
    console.log('[spotify/token] Token expired or expiring, refreshing...');
    return await refreshAuthToken(tokens.refresh_token);
  }

  return {
    accessToken: tokens.oauth_token,
    refreshToken: tokens.refresh_token,
    expiresAt: tokens.expires_at
  };
}

export async function createSpotifyClient(deviceId: string):
  Promise<SpotifyApi | null> {
  console.log(`[spotify/client] Creating client for device ${deviceId}`);
  const result = getOauthTokens(deviceId, 'spotify');
  if (!result) {
    console.warn('[spotify/client] No tokens found');
    return null;
  }

  let { oauth_token, refresh_token, expires_at } = result;
  const timeLeft = expires_at - Date.now();
  console.log(`[spotify/client] Token expires in ${Math.round(timeLeft / 1000)}s`);

  if (timeLeft < 30 * 1000) {
    console.log('[spotify/client] Token expiring soon, refreshing...');
    const newTokens = await refreshAuthToken(result.refresh_token);

    saveAccessTokens(deviceId, 'spotify', newTokens);

    oauth_token = newTokens.accessToken;
    refresh_token = newTokens.refreshToken;
    expires_at = newTokens.expiresAt;
  }

  console.log('[spotify/client] Client created successfully');
  return SpotifyApi.withAccessToken(process.env.SPOTIFY_CLIENT_ID!, {
    access_token: oauth_token,
    refresh_token,
    token_type: "Bearer",
    expires_in: Math.floor((expires_at - Date.now()) / 1000),
  });
}

export async function getAccessTokenFromCode(code: string): Promise<AuthData | null> {
  console.log('[spotify/auth] Exchanging code for tokens...');
  const redirectUri = process.env.SPOTIFY_REDIRECT_URI;
  const clientId = process.env.SPOTIFY_CLIENT_ID;
  const clientSecret = process.env.SPOTIFY_SECRET;

  if (!redirectUri || !clientId || !clientSecret) {
    console.error('[spotify/auth] Missing env vars (REDIRECT_URI, CLIENT_ID, or SECRET)');
    return null;
  }

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

  if (!response.ok) {
    console.error(`[spotify/auth] Token exchange failed (${response.status})`);
    return null;
  }

  const data = await response.json();
  console.log('[spotify/auth] Token exchange successful');

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
  console.log(`[spotify/items] Fetching items: playlist=${playlistId}, limit=${limit}, offset=${offset}`);
  const result = getOauthTokens(deviceId, 'spotify');
  if (!result) {
    console.warn('[spotify/items] No tokens found');
    return null;
  }

  let { oauth_token, refresh_token, expires_at } = result;

  if (result.expires_at - Date.now() < 30 * 1000) {
    console.log('[spotify/items] Token expiring soon, refreshing...');
    const newTokens = await refreshAuthToken(result.refresh_token);

    saveAccessTokens(deviceId, 'spotify', newTokens);

    oauth_token = newTokens.accessToken;
    refresh_token = newTokens.refreshToken;
    expires_at = newTokens.expiresAt;
  }

  const url = `https://api.spotify.com/v1/playlists/${playlistId}/items?limit=${limit}&offset=${offset}`;
  console.log(`[spotify/items] GET ${url}`);

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${oauth_token}` }
  });

  if (!res.ok) {
    const body = await res.text();
    console.error(`[spotify/items] Spotify API error (${res.status}):`, body);

    if (res.status === 403) {
      throw new Error('You don\'t have access to this playlist. It may be private or owned by another user.');
    }
    if (res.status === 404) {
      throw new Error('Playlist not found. It may have been deleted.');
    }

    throw new Error(`Spotify error: ${res.status}`);
  }

  const data = await res.json();
  const filteredData = SpotifyPlaylistItemsSchema.parse(data);

  console.log(`[spotify/items] Got ${filteredData.items.length} items, total=${filteredData.total}`);

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

export async function createNewPlaylist(
  deviceId: string,
  title: string,
  description: string) {
  console.log(`[spotify/create] Creating playlist: "${title}"`);
  const tokens = await getAccessToken(deviceId);
  if (!tokens)
    throw new Error("Failed to authenticate with Spotify API");

  const res = await fetch("https://api.spotify.com/v1/me/playlists", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${tokens.accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      name: title,
      description: description.replace(/[?&=]/g, ' '),
      public: false,
    }),
  });

  const playlist = await res.json();
  console.log(`[spotify/create] Response:`, playlist);

  if (!playlist.id)
    throw new Error("Failed to create Spotify Playlist :(");

  console.log(`[spotify/create] Created playlist with id=${playlist.id}`);
  return playlist.id;
}

export async function addItemsToPlaylist(
  deviceId: string,
  playlistId: string,
  uris: string[]
) {
  console.log(`[spotify/add] Adding ${uris.length} items to playlist ${playlistId}`);
  const tokens = await getAccessToken(deviceId);
  if (!tokens)
    throw new Error("Failed to authenticate with Spotify API");

  const res = await fetch(`https://api.spotify.com/v1/playlists/${playlistId}/items`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${tokens.accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ uris }),
  });

  console.log(`[spotify/add] Response status: ${res.status}`);
  return res;
}

export async function getAllPlaylistItems(deviceId: string, playlistId: string):
  Promise<PlaylistItem[] | null> {
  console.log(`[spotify/allItems] Starting full fetch for playlist ${playlistId}`);
  const spotify = await createSpotifyClient(deviceId);
  if (!spotify) {
    console.warn('[spotify/allItems] Failed to create client');
    return null;
  }

  let offset = 0;
  const contents: PlaylistItem[] = [];

  while (true) {
    console.log(`[spotify/allItems] Batch fetch: offset=${offset}`);
    const response = await getPlaylistItems(playlistId, deviceId, 100, offset);

    if (!response) {
      console.warn('[spotify/allItems] getPlaylistItems returned null, stopping');
      break;
    }

    contents.push(...response.items);
    console.log(`[spotify/allItems] Accumulated ${contents.length} items`);

    if (response.next) {
      offset += 100;
    } else break;
  }

  console.log(`[spotify/allItems] Done. Total: ${contents.length} items`);
  return contents;
}