import spotify from "./services/spotify_service";

const res = await spotify.search("Charles", ["track"]);
console.log(JSON.stringify(res));