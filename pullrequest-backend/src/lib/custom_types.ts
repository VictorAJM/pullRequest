import { z } from 'zod';

export type Platform = "ytm" | "spotify";

export interface Track {
    id: string,
    name: string,
    album: string,
    artists: Array<string>,
    platform: Platform
}

export interface User {
    device_id: string,
    public_key: string,
    ytm_oauth_token: string | null,
    ytm_refresh_token: string | null,
    ytm_expires_at: number,
    spotify_oauth_token: string | null,
    spotify_refresh_token: string | null,
    spotify_expires_at: number
}

export interface AuthData {
    accessToken: string,
    refreshToken: string,
    expiresAt: number
}

export interface Thumbnail {
    url: string,
    height: number,
    width: number
}

export interface Playlist {
    platform: Platform,
    id: string,
    title: string,
    itemCount: number,
    thumbnail: Thumbnail
}

export interface PlaylistItem {
    platform: Platform,
    id: string,
    title: string,
    artist: string,
    thumbnail: Thumbnail
}

const SpotifyItemSchema = z.object({
    item: z.object({
        id: z.string(),
        name: z.string(),
        album: z.object({
            images: z.array(z.object({
                url: z.string(),
                height: z.number(),
                width: z.number()
            }))
        }),
        artists: z.array(z.object({
            name: z.string()
        }))
    })
});

export const SpotifyPlaylistItemsSchema = z.object({
    total: z.number(),
    items: z.array(SpotifyItemSchema)
}).transform((data) => {
    return {
        ...data,
        items: data.items
            .map((item) => SpotifyItemSchema.safeParse(item))
            .filter((result) => result.success)
            .map((result) => result.data),
    };
});

export interface PlaylistItems {
    next: boolean,
    items: PlaylistItem[]
}

export interface transferUpdateMessage {
    status: 'starting' | 'in_progress' | 'completed' | 'error',
    totalItems: number | undefined,
    currentItem: number | undefined,
    current_song: string | undefined,
    current_thumbnail?: string,
    platformFrom?: Platform,
    failedItems?: PlaylistItem[]
}