import { translateTrack } from "@lib/track_translate";
import { Track, Platform } from "@lib/custom_types";

const t1: Track = { id: "", name: "Upside Down", artists: ["Black Gryph0n", "Baasik"], album: "Upside Down", platform: "ytm" };
const r = await translateTrack(t1);
console.log(r);


const t2: Track = { id: "", name: "Exorcism", artists: ["Creep-P"], album: "TV (Deluxe Edition)", platform: "spotify" };
const r2 = await translateTrack(t2);
console.log(r2);