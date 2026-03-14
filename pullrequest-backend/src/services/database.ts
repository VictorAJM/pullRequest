import { Database } from "bun:sqlite";
import { Platform } from "@lib/custom_types";

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

export function getOauthTokens(deviceId: string, platform: Platform): {
  oauth_token: string,
  refresh_token: string,
  expires_at: number
} | null {
  return db.prepare(`
          SELECT
            ${platform}_oauth_token as oauth_token,
            ${platform}_refresh_token as refresh_token,
            ${platform}_expires_at as expires_at
          FROM users 
          WHERE device_id = $deviceId
        `).get({
    $deviceId: deviceId
  }) as { oauth_token: string, refresh_token: string, expires_at: number } | null;
}

export function saveOauthTokens(
  deviceId: string,
  platform: Platform,
  oauthToken: string,
  refreshToken: string,
  expiresAt: number
) {
  db.prepare(`
      UPDATE users SET 
        ${platform}_oauth_token = $oauth_token, 
        ${platform}_refresh_token = $refresh_token, 
        ${platform}_expires_at = $expiry_date 
      WHERE device_id = $device_id
    `).run({
    $oauth_token: oauthToken,
    $refresh_token: refreshToken,
    $expiry_date: expiresAt,
    $device_id: deviceId
  });
}