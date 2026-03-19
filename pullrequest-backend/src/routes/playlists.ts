import { Elysia, t } from 'elysia';
import { youtube_v3 } from 'googleapis';
import { createYouTubeClient } from '@services/youtube_api_client';
import { createSpotifyClient, getPlaylistItems } from '@services/spotify_api_client';
import { PlaylistedTrack, Track, SimplifiedPlaylist } from '@spotify/web-api-ts-sdk'
import { Playlist, PlaylistItem } from '@lib/custom_types';

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
        } :
          { url: '', height: 0, width: 0 }
      }));

      return filteredPlaylists;
    } else {
      const spotify = await createSpotifyClient(deviceId);
      if (!spotify) return status(401, 'User not authenticated with Spotify');

      let offset = 0;
      const playlists: SimplifiedPlaylist[] = [];

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

      if (playlists.length > 0)
        console.log(playlists[0]);

      const filteredPlaylists: Playlist[] = playlists.map(playlist => ({
        platform: 'spotify',
        id: playlist.id,
        title: playlist.name,
        itemCount: playlist.items.total,
        thumbnail: playlist.images[0]
      }));

      return filteredPlaylists;
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

      const contents: youtube_v3.Schema$PlaylistItem[] = [];
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

      return filteredContents;
    } else {

      const spotify = await createSpotifyClient(deviceId);
      if (!spotify) return status(401, 'User not authenticated with Spotify');

      let offset = 0;
      const contents: PlaylistItem[] = [];

      while (true) {
        const response = await getPlaylistItems(playlist_id, deviceId, 100, offset);

        if (!response) break;

        contents.push(...response.items);

        if (response.next) {
          offset += 100;
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