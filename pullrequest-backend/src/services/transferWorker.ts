import { createYouTubeClient, getAllPlaylistItems as getAllYoutubePlaylistItems } from '@services/youtube_api_client';
import { createSpotifyClient, getAllPlaylistItems as getAllSpotifyPlaylistImtes, createNewPlaylist, addItemsToPlaylist } from '@services/spotify_api_client';
import { youtube_v3 } from 'googleapis';
import { translateTrack } from '@lib/track_translate';
import { PlaylistItem } from '@lib/custom_types';

const ctx: Worker = self as any;

ctx.onmessage = async (event: MessageEvent) => {
  const { deviceId, playlistId, platformFrom } = event.data;

  console.log('Starting playlist transfer...');

  try {
    const playlistItems = (platformFrom === 'ytm' ?
      await getAllYoutubePlaylistItems(deviceId, playlistId) :
      await getAllSpotifyPlaylistImtes(deviceId, playlistId));

    if (!playlistItems) {
      ctx.postMessage({ status: 'error' });
      throw new Error("Failed to get playlist items.");
    }

    const youtubeClient = await createYouTubeClient(deviceId);
    let spotifyClient = await createSpotifyClient(deviceId);

    if (!youtubeClient)
      throw Error("Failed to connect to Google API.");
    if (!spotifyClient)
      throw Error("Failed to connect to Spotify API.");

    if (platformFrom === 'ytm') {
      const detailsResponse = await youtubeClient.playlists.list({
        part: ['snippet'],
        id: [playlistId]
      });

      const items = detailsResponse.data.items;
      if (!items || items.length == 0 || !items[0].snippet?.title) {
        ctx.postMessage({ status: 'error' });
        throw new Error("Input playlist was not found");
      }

      const playlistName = items[0].snippet.title;
      const newPlaylistId = await createSpotifyPlaylist(
        deviceId,
        playlistName,
        playlistId
      );

      let currentItem = 1;
      const failedItems: PlaylistItem[] = [];

      for (const batch of chunkGenerator(playlistItems, 100)) {
        const spotifyTracks: string[] = [];
        for (const track of batch) {
          ctx.postMessage({
            status: 'in_progress',
            current_song: track.title,
            current_thumbnail: track.thumbnail?.url,
            platformFrom,
            totalItems: playlistItems.length,
            currentItem
          });
          const translated = await translateTrack(track, 'spotify');

          if (translated.id !== 'Not Found :(')
            spotifyTracks.push(`spotify:track:${translated.id}`);
          else
            failedItems.push(track);
          currentItem++;
        }

        const response = await addItemsToPlaylist(
          deviceId,
          newPlaylistId,
          spotifyTracks
        );

        if (response.status != 201) {
          console.log("Fuckk??: ", await response)
        }
      }

      ctx.postMessage({
        status: 'completed',
        totalItems: playlistItems.length,
        failedItems
      });
    } else {
      const response = await spotifyClient.playlists.getPlaylist(
        playlistId, undefined, 'name'
      );

      const playlistName = response.name;
      const newPlaylistId = await createYoutubePlaylist(
        youtubeClient,
        playlistName,
        playlistId
      );

      var currentItem = 1;
      const failedItems: PlaylistItem[] = [];

      for (const track of playlistItems) {
        ctx.postMessage({
          status: 'in_progress',
          current_song: track.title,
          current_thumbnail: track.thumbnail?.url,
          platformFrom,
          totalItems: playlistItems.length,
          currentItem
        });
        const translated = await translateTrack(track, 'ytm');

        if (translated.id === "Not Found :(") {
          failedItems.push(track);
          currentItem++;
          continue;
        }

        const success = await insertWithRetry(youtubeClient, newPlaylistId, translated.id);
        if (!success) failedItems.push(track);

        currentItem++;
        await Bun.sleep(350);
      }
      ctx.postMessage({
        status: 'completed',
        totalItems: playlistItems.length,
        failedItems
      });
    }
  } catch (error) {
    console.log("Oh fuckyy: ", error);
    ctx.postMessage({ status: "error" });
  }
};

async function insertWithRetry(
  client: youtube_v3.Youtube,
  playlistId: string,
  videoId: string,
  retries = 3
): Promise<boolean> {
  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      await client.playlistItems.insert({
        part: ['snippet'],
        requestBody: {
          snippet: {
            playlistId,
            resourceId: {
              kind: 'youtube#video',
              videoId
            }
          }
        }
      });
      return true;
    } catch (err: any) {
      if (err?.status === 409) return true; // duplicate, not a failure
      if (attempt < retries - 1) {
        await Bun.sleep(1000 * (attempt + 1)); // 1s, 2s, 3s
      }
    }
  }
  return false;
}

async function createYoutubePlaylist(
  client: youtube_v3.Youtube,
  playlistName: string,
  playlistId: string
): Promise<string> {
  const response = await client.playlists.insert({
    part: ['snippet', 'status'],
    requestBody: {
      snippet: {
        title: playlistName,
        description: `Playlist transfered from Spotify via pullRequest app.\nOriginal playlist: https://open.spotify.com/playlist/${playlistId}`,
      },
      status: {
        privacyStatus: 'private'
      }
    }
  });

  if (!response.data.id)
    throw new Error("Failed to create YouTube playlist");

  return response.data.id;
}

async function createSpotifyPlaylist(
  deviceId: string,
  playlistName: string,
  playlistId: string
): Promise<string> {
  return await createNewPlaylist(
    deviceId,
    playlistName,
    `Playlist transfered from YouTube Music via ppullRequest app.(Spotify is a bith and does not allow to include the url to ytm)`
  );
}

function* chunkGenerator<T>(array: T[], size: number) {
  for (let i = 0; i < array.length; i += size) {
    yield array.slice(i, i + size);
  }
}