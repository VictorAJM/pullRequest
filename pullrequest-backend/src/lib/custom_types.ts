export type Platform = "ytm" | "spotify";

export interface Track {
    id: string,
    name: string,
    album: string,
    artists: Array<string>,
    platform: Platform
}