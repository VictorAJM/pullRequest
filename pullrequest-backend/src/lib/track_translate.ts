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

        // --- INVIDIOUS FALLBACK ---
        try {
            const query = encodeURIComponent(`${track.title} ${track.artist} song`);

            const invRes = await fetch(
                `https://yewtu.be/api/v1/search?q=${query}`
            );

            if (!invRes.ok) throw new Error(`Invidious returned status ${invRes.status}`);

            const data = await invRes.json();

            if (Array.isArray(data) && data.length > 0) {
                const item = data.find((i: any) => i.type === 'video') || data[0];
                const videoId = item?.videoId;

                if (videoId) {
                    return { ...track, platform: "ytm", id: videoId };
                }
            }
        } catch (invErr) {
            console.error(`Invidious fallback failed for "${track.title}" - ${invErr}`);
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