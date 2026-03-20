import { Platform, Track } from "@lib/custom_types";
import spotify from "@services/spotify_service";
import YTMusic from "ytmusic-api";

const ytm = new YTMusic();
await ytm.initialize();

export async function translateTrack(track: Track, platform?: Platform):
    Promise<Track> {
    if (!platform) {
        platform = (track.platform === "ytm" ? "spotify" : "ytm");
    }

    if (platform === "ytm") {
        return ytmSearch(track);
    } else {
        return spotifySearch(track);
    }
}

async function ytmSearch(track: Track): Promise<Track> {
    const res = await ytm.searchSongs(
        `track:${track.name} album:${track.album} artist:${track.artists[0]}`);

    if (res.length > 0) {
        return { ...track, platform: "ytm", id: res[0].videoId }
    }

    return { ...track, platform: "ytm", id: "Not Found :(" };
}

async function spotifySearch(track: Track): Promise<Track> {
    const res = await spotify.search(
        `track:${track.name} album:${track.album} artist:${track.artists[0]}`,
        ["track"]);

    if (res.tracks.items.length > 0) {
        return { ...track, platform: "spotify", id: res.tracks.items[0].id };
    }

    return { ...track, platform: "spotify", id: "Not Found :(" };
}   