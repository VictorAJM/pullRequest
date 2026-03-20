import { google, youtube_v3 } from 'googleapis';
import { OAuth2Client } from 'google-auth-library';
import { getOauthTokens, saveAccessTokens } from './database';
import { AuthData } from '@lib/custom_types';

const oauthClient = new OAuth2Client(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI
);

export function createYouTubeClient(deviceId: string): youtube_v3.Youtube | null {
  const result = getOauthTokens(deviceId, 'ytm');
  if (!result) return null;

  const oauth2Client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET
  );

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

    saveAccessTokens(
      deviceId,
      'ytm',
      {
        accessToken: tokens.access_token,
        refreshToken,
        expiresAt: newExpiry
      }
    );
  });

  return google.youtube({ version: 'v3', auth: oauth2Client });
}

export async function getAccessTokenFromCode(code: string): Promise<AuthData | null> {
  try {
    const { tokens } = await oauthClient.getToken(code);

    if (!tokens.access_token || !tokens.refresh_token || !tokens.expiry_date)
      return null;

    return {
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresAt: tokens.expiry_date
    };
  } catch (error) {
    return null;
  }
}