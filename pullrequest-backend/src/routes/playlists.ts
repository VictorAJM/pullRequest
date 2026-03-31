import { Elysia, t } from 'elysia';
import { youtube_v3 } from 'googleapis';
import { createYouTubeClient, getAllPlaylistItems as getAllYoutubePlaylistItems } from '@services/youtube_api_client';
import { createSpotifyClient, getAllPlaylistItems as getAllSpotifyPlaylistImtes } from '@services/spotify_api_client';
import { SimplifiedPlaylist } from '@spotify/web-api-ts-sdk'
import { Playlist, PlaylistItem } from '@lib/custom_types';

export const playlistsRoutes = new Elysia({ prefix: 'playlists' })
  .get('/list', async ({ query, headers, status }) => {
    const { platform } = query;
    const deviceId = headers['x-device-id'];

    console.log(`[playlists/list] platform=${platform}, deviceId=${deviceId}`);

    if (!deviceId) {
      console.warn('[playlists/list] Missing x-device-id header');
      return status(400, 'Missing device ID');
    }

    try {
      if (platform === 'ytm') {
        const youtube = createYouTubeClient(deviceId);
        if (!youtube) {
          console.warn('[playlists/list] YouTube client not authenticated');
          return status(401, 'User not authenticated with Google');
        }

        const playlists: youtube_v3.Schema$Playlist[] = [];
        let paginationToken: string | undefined = undefined;
        let page = 0;

        while (true) {
          page++;
          console.log(`[playlists/list] YouTube: fetching page ${page}...`);

          const response: any = await youtube.playlists.list({
            part: ['snippet', 'contentDetails'],
            mine: true,
            maxResults: 50,
            pageToken: paginationToken
          });

          if (response.data.items) {
            playlists.push(...response.data.items);
          }

          paginationToken = response.data.nextPageToken ?? undefined;
          if (!paginationToken) break;
        }

        console.log(`[playlists/list] YouTube: fetched ${playlists.length} playlists total`);

        const filteredPlaylists: Playlist[] = playlists.map(playlist => ({
          platform: 'ytm',
          id: playlist.id || '',
          title: playlist.snippet?.localized?.title || '',
          itemCount: playlist.contentDetails?.itemCount || 0,
          thumbnail: (playlist.snippet?.thumbnails?.high?.url &&
            playlist.snippet?.thumbnails?.high?.width &&
            playlist.snippet?.thumbnails?.high?.height) ? {
            url: playlist.snippet.thumbnails.high.url,
            width: playlist.snippet.thumbnails.high.width,
            height: playlist.snippet.thumbnails.high.height
          } : { url: '', height: 0, width: 0 }
        }));

        return filteredPlaylists;
      } else {
        const spotify = await createSpotifyClient(deviceId);
        if (!spotify) {
          console.warn('[playlists/list] Spotify client not authenticated');
          return status(401, 'User not authenticated with Spotify');
        }

        let offset = 0;
        const playlists: SimplifiedPlaylist[] = [];

        while (true) {
          console.log(`[playlists/list] Spotify: fetching offset=${offset}...`);

          const response = await spotify.currentUser.playlists.playlists(50, offset);
          playlists.push(...response.items);

          if (response.next) {
            offset += 50;
          } else break;
        }

        console.log(`[playlists/list] Spotify: fetched ${playlists.length} playlists total`);

        const filteredPlaylists: Playlist[] = playlists.map(playlist => ({
          platform: 'spotify',
          id: playlist.id,
          title: playlist.name,
          itemCount: playlist.items.total,
          thumbnail: playlist.images[0]
        }));

        return filteredPlaylists;
      }
    } catch (error) {
      console.error('[playlists/list] Unhandled error:', error);
      return status(500, 'Internal server error loading playlists');
    }
  }, {
    query: t.Object({
      platform: t.Union([t.Literal('ytm'), t.Literal('spotify')])
    })
  })

  .get('/contents', async ({ query, headers, status }) => {
    const { playlist_id, platform } = query;
    const deviceId = headers['x-device-id'];

    console.log(`[playlists/contents] platform=${platform}, playlistId=${playlist_id}, deviceId=${deviceId}`);

    if (!deviceId) {
      console.warn('[playlists/contents] Missing x-device-id header');
      return status(400, 'Missing device ID');
    }

    try {
      if (platform === 'ytm') {
        console.log('[playlists/contents] Fetching YouTube playlist items...');
        const playlistItems = await getAllYoutubePlaylistItems(deviceId, playlist_id);

        if (!playlistItems) {
          console.warn('[playlists/contents] YouTube returned null — not authenticated');
          return status(401, 'User not authenticated with Google');
        }

        console.log(`[playlists/contents] YouTube: fetched ${playlistItems.length} items`);
        return playlistItems;
      } else {
        console.log('[playlists/contents] Fetching Spotify playlist items...');
        const playlistItems = await getAllSpotifyPlaylistImtes(deviceId, playlist_id);

        if (!playlistItems) {
          console.warn('[playlists/contents] Spotify returned null — not authenticated');
          return status(401, 'User not authenticated with Spotify');
        }

        console.log(`[playlists/contents] Spotify: fetched ${playlistItems.length} items`);
        return playlistItems;
      }
    } catch (error: any) {
      console.error(`[playlists/contents] Error for playlist ${playlist_id}:`, error);
      const message = error?.message || 'Internal server error';
      return status(500, message);
    }
  }, {
    query: t.Object({
      playlist_id: t.String(),
      platform: t.Union([t.Literal('ytm'), t.Literal('spotify')])
    })
  });