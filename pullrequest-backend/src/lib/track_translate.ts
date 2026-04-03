import { Platform, PlaylistItem, Track } from "@lib/custom_types";
import spotify from "@services/spotify_service";
import YTMusic from "ytmusic-api";

const ytm = new YTMusic();
await ytm.initialize();

export async function translateTrack(track: PlaylistItem, platform?: Platform):
    Promise<PlaylistItem> {
    if (!platform) {
        platform = (track.platform === "ytm" ? "spotify" : "ytm");
    }

    if (platform === "ytm") {
        return await ytmSearch(track);
    } else {
        return await spotifySearch(track);
    }
}

async function ytmSearch(track: PlaylistItem): Promise<PlaylistItem> {
    try {
        const res = await Promise.race([
            ytm.searchSongs(`${track.title} ${track.artist}`),
            new Promise<any[]>((_, reject) =>
                setTimeout(() => reject(new Error('YTM Search Timeout')), 1000)
            )
        ]);

        if (res.length > 0) {
            return { ...track, platform: "ytm", id: res[0].videoId }
        }
    } catch (err) {
        console.warn(`YTM API failed for "${track.title}", falling back to Piped...`);

        // --- PIPED FALLBACK ---
        try {
            const query = encodeURIComponent(`${track.title} ${track.artist}`);
            const pipedRes = await fetch(
                `https://pipedapi.kavin.rocks/search?q=${query}&filter=music_songs`
            );

            if (!pipedRes.ok) throw new Error(`Piped returned status ${pipedRes.status}`);

            const data = await pipedRes.json();
            if (data.items && data.items.length > 0) {
                const item = data.items[0];
                const url = item.url || "";
                let videoId = "";

                if (url.includes("?v=")) {
                    videoId = url.split("?v=")[1];
                } else if (url.includes("/watch/")) {
                    videoId = url.replace("/watch/", "");
                }

                videoId = videoId.split("&")[0];

                if (videoId) {
                    return { ...track, platform: "ytm", id: videoId };
                }
            }
        } catch (pipedErr) {
            console.error(`Piped fallback failed for "${track.title}" - ${pipedErr}`);
        }
    }

    return { ...track, platform: "ytm", id: "Not Found :(" };
}

async function spotifySearch(track: PlaylistItem): Promise<PlaylistItem> {
    const res = await spotify.search(
        `track:${track.title} artist:${track.artist}`,
        ["track"]);

    if (res.tracks.items.length > 0) {
        return { ...track, platform: "spotify", id: res.tracks.items[0].id };
    }

    return { ...track, platform: "spotify", id: "Not Found :(" };
}   