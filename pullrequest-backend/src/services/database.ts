import { Database } from "bun:sqlite";

export const db = new Database("mydb.sqlite");
db.run(`
  CREATE TABLE IF NOT EXISTS users (
    device_id TEXT PRIMARY KEY,
    public_key TEXT NOT NULL,
    ytm_oauth_token TEXT,
    ytm_refresh_token TEXT,
    ytm_expires_at INTEGER,
    spotify_oauth_token TEXT,
    spotify_refresh_token TEXT,
    spotify_expires_at INTEGER
)`);