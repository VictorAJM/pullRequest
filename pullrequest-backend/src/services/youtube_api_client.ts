import { google, youtube_v3 } from 'googleapis';
import { OAuth2Client } from 'google-auth-library';
import { getOauthTokens, saveAccessTokens, getCachedPlaylist, savePlaylistCache } from './database';
import { AuthData, PlaylistItem } from '@lib/custom_types';

const oauthClient = new OAuth2Client(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI
);

export function createYouTubeClient(deviceId: string): youtube_v3.Youtube | null {
  const result = getOauthTokens(deviceId, 'ytm');
  if (!result) return null;

  const oauth2Client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET
  );

  oauth2Client.setCredentials({
    access_token: result.oauth_token,
    refresh_token: result.refresh_token,
    expiry_date: result.expires_at
  });

  oauth2Client.on('tokens', (tokens) => {
    console.log('🔄 Google token expired! Auto-refreshing...');

    if (!tokens.access_token) {
      return;
    }

    const newExpiry = tokens.expiry_date || (Date.now() + 3600000);
    const refreshToken = tokens.refresh_token || result.refresh_token;

    saveAccessTokens(
      deviceId,
      'ytm',
      {
        accessToken: tokens.access_token,
        refreshToken,
        expiresAt: newExpiry
      }
    );
  });

  return google.youtube({ version: 'v3', auth: oauth2Client });
}

export async function getAccessTokenFromCode(code: string): Promise<AuthData | null> {
  try {
    const { tokens } = await oauthClient.getToken(code);

    if (!tokens.access_token || !tokens.refresh_token || !tokens.expiry_date)
      return null;

    return {
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresAt: tokens.expiry_date
    };
  } catch (error) {
    return null;
  }
}

export async function getAllPlaylistItems(deviceId: string, playlistId: string):
  Promise<PlaylistItem[] | null> {
  const youtube = createYouTubeClient(deviceId);
  if (!youtube) return null;

  const cachedResponse = getCachedPlaylist(playlistId, 'ytm', deviceId);

  try {
    const playlistMeta = await youtube.playlists.list({
      id: [playlistId],
      part: ['snippet']
    });
    const etag = playlistMeta.data.etag ?? '';

    if (cachedResponse && cachedResponse.snapshot === etag) {
      console.log("playlist hasn't changed, using local cache.");
      return cachedResponse.data;
    }

    const contents: youtube_v3.Schema$PlaylistItem[] = [];
    let paginationToken: string | undefined = undefined;


    while (true) {
      const response: any = await youtube.playlistItems.list({
        part: ['snippet', 'contentDetails'],
        playlistId: playlistId,
        maxResults: 50,
        pageToken: paginationToken
      });

      if (response.data.items) {
        contents.push(...response.data.items);
      }

      paginationToken = response.data.nextPageToken ?? undefined;
      if (!paginationToken) break;
    }

    const filteredContents: PlaylistItem[] = contents.map(item => ({
      platform: 'ytm',
      id: item.snippet?.resourceId?.videoId || '',
      title: item.snippet?.title || '',
      artist: item.snippet?.videoOwnerChannelTitle ?
        item.snippet?.videoOwnerChannelTitle.replace(/\s-\sTopic\s*$/, "")
        : "??",
      thumbnail: (item.snippet?.thumbnails?.high?.url &&
        item.snippet?.thumbnails?.high?.width &&
        item.snippet?.thumbnails?.high?.height) ? {
        url: item.snippet.thumbnails.high.url,
        width: item.snippet.thumbnails.high.width,
        height: item.snippet.thumbnails.high.height
      } :
        { url: '', height: 0, width: 0 }
    }));

    savePlaylistCache(playlistId, 'ytm', deviceId, filteredContents, etag);

    return filteredContents;
  } catch (error: any) {
    if (cachedResponse) {
      console.log("Oh noeyy we have an error: Using local cache instead.");
      return cachedResponse.data;
    } else {
      throw error;
    }
  }
}