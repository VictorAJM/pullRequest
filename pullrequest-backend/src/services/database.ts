import { Database } from "bun:sqlite";
import { Platform, AuthData, PlaylistItem } from "@lib/custom_types";
import { snapshot } from "node:test";

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

db.run(`
  CREATE TABLE IF NOT EXISTS playlist_cache (
    playlist_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    platform TEXT NOT NULL,
    snapshot_id TEXT,
    data TEXT,
    PRIMARY KEY (playlist_id, device_id, platform)
)`);

export function getOauthTokens(deviceId: string, platform: Platform): {
  oauth_token: string,
  refresh_token: string,
  expires_at: number
} | null {
  const result = db.prepare(`
          SELECT
            ${platform}_oauth_token as oauth_token,
            ${platform}_refresh_token as refresh_token,
            ${platform}_expires_at as expires_at
          FROM users 
          WHERE device_id = $deviceId
        `).get({
    $deviceId: deviceId
  }) as { oauth_token: string | null, refresh_token: string | null, expires_at: number | null } | null;

  // Verificamos si no hay resultado, o si el token viene nulo
  if (!result || !result.oauth_token) {
    return null;
  }

  return {
    oauth_token: result.oauth_token,
    refresh_token: result.refresh_token!,
    expires_at: result.expires_at!
  };
}

export function saveAccessTokens(
  deviceId: string,
  platform: Platform,
  authData: AuthData
) {
  db.prepare(`
      UPDATE users SET 
        ${platform}_oauth_token = $oauth_token, 
        ${platform}_refresh_token = $refresh_token, 
        ${platform}_expires_at = $expiry_date 
      WHERE device_id = $device_id
    `).run({
    $oauth_token: authData.accessToken,
    $refresh_token: authData.refreshToken,
    $expiry_date: authData.expiresAt,
    $device_id: deviceId
  });
}

export function getCachedPlaylist(
  playlistId: string,
  platform: Platform,
  deviceId: string
) {
  const result = db.prepare(`
          SELECT
            snapshot_id,
            data
          FROM playlist_cache 
          WHERE
            playlist_id = $playlistId AND
            device_id = $deviceId AND
            platform = $platform
        `).get({
    $deviceId: deviceId,
    $playlistId: playlistId,
    $platform: platform
  }) as { snapshot_id: string, data: string } | undefined;

  if (!result) return null;

  try {
    return {
      snapshot: result.snapshot_id,
      data: JSON.parse(result.data)
    };
  } catch (error) {
    return null;
  }
}

export function savePlaylistCache(
  playlistId: string,
  platform: Platform,
  deviceId: string,
  data: PlaylistItem[],
  snapshot: string
) {
  const upsertPlaylist = db.prepare(`
  INSERT INTO playlist_cache (
    playlist_id, 
    platform, 
    device_id, 
    data, 
    snapshot_id
  ) 
  VALUES (
    $playlistId, 
    $platform, 
    $deviceId, 
    $data, 
    $snapshot
  )
  ON CONFLICT(playlist_id, platform, device_id) DO UPDATE SET
    data = excluded.data,
    snapshot_id = excluded.snapshot_id
`);

  upsertPlaylist.run({
    $playlistId: playlistId,
    $platform: platform,
    $deviceId: deviceId,
    $data: JSON.stringify(data),
    $snapshot: snapshot
  });
}