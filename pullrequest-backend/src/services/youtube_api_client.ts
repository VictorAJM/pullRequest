import { google, youtube_v3 } from 'googleapis';
import { getOauthTokens, db } from './database';

export function createYouTubeClient(deviceId: string): youtube_v3.Youtube | null {
  const oauth2Client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET
  );

  const result = getOauthTokens(deviceId, 'ytm');
  if (!result) return null;

  oauth2Client.setCredentials({
    access_token: result.oauth_token,
    refresh_token: result.refresh_token,
    expiry_date: result.expires_at
  });

  oauth2Client.on('tokens', (tokens) => {
    console.log('🔄 Google token expired! Auto-refreshing...');

    if (!tokens.access_token) {
      return;
    }

    const newExpiry = tokens.expiry_date || (Date.now() + 3600000);
    const refreshToken = tokens.refresh_token || result.refresh_token;

    db.prepare(`
      UPDATE users SET 
        ytm_oauth_token = $oauth_token, 
        ytm_refresh_token = $refresh_token, 
        ytm_expires_at = $expiry_date 
      WHERE device_id = $device_id
    `).run({
      $oauth_token: tokens.access_token,
      $refresh_token: refreshToken,
      $expiry_date: newExpiry,
      $device_id: deviceId
    });
  });

  return google.youtube({ version: 'v3', auth: oauth2Client });
}