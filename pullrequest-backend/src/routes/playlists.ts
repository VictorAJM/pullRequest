import { Elysia, t } from 'elysia';
import { youtube_v3 } from 'googleapis';
import { createYouTubeClient } from '@services/youtube_api_client';
import { createSpotifyClient } from '@services/spotify_api_client';

export const playlistsRoutes = new Elysia({ prefix: 'playlists' })
  .get('/list', async ({ query, headers, status }) => {
    const { platform } = query;

    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    if (platform === 'ytm') {
      const youtube = createYouTubeClient(deviceId);
      if (!youtube) return status(401, 'User not authenticated with Google');

      const playlists: youtube_v3.Schema$Playlist[] = [];
      let paginationToken: string | undefined = undefined;

      while (true) {
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

      return playlists;
    } else {
      const spotify = await createSpotifyClient(deviceId);
      if (!spotify) return status(401, 'User not authenticated with Spotify');

      let offset = 0;
      const playlists = [];

      while (true) {
        const response = await spotify.currentUser.playlists.playlists(
          50,
          offset
        );

        playlists.push(...response.items);

        if (response.next) {
          offset += 50;
        } else break;
      }

      return playlists;
    }

  }, {
    query: t.Object({
      platform: t.Union([
        t.Literal('ytm'),
        t.Literal('spotify')
      ])
    })
  })
  .get('/contents', async ({ query, headers, status }) => {
    const { playlist_id, platform } = query;

    const deviceId = headers['x-device-id'];
    if (!deviceId) {
      return;
    }

    if (platform === 'ytm') {
      const youtube = createYouTubeClient(deviceId);
      if (!youtube) return status(401, 'User not authenticated with Google');

      const contents: youtube_v3.Schema$PlaylistItemListResponse[] = [];
      let paginationToken: string | undefined = undefined;

      while (true) {
        const response: any = await youtube.playlistItems.list({
          part: ['snippet'],
          playlistId: playlist_id,
          maxResults: 50,
          pageToken: paginationToken
        });

        if (response.data.items) {
          contents.push(...response.data.items);
        }

        paginationToken = response.data.nextPageToken ?? undefined;
        if (!paginationToken) break;
      }

      return contents;
    } else {
      const spotify = await createSpotifyClient(deviceId);
      if (!spotify) return status(401, 'User not authenticated with Spotify');

      let offset = 0;
      const contents = [];

      while (true) {
        const response = await spotify.playlists.getPlaylistItems(
          playlist_id,
          undefined,
          undefined,
          50,
          offset
        );

        contents.push(...response.items);

        if (response.next) {
          offset += 50;
        } else break;
      }

      return contents;
    }

  }, {
    query: t.Object({
      playlist_id: t.String(),
      platform: t.Union([
        t.Literal('ytm'),
        t.Literal('spotify')
      ])
    })
  });