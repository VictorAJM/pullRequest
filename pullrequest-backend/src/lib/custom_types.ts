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