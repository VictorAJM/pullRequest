import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/config/spotify_scopes.dart';
import '../core/errors/app_exception.dart';
import '../models/authorization_result.dart';
import '../models/music_platform.dart';
import '../repositories/auth_repository.dart';

/// Thin interface over [FlutterSecureStorage] so [SpotifyAuthService] can be
/// unit-tested without platform-channel setup.
abstract interface class TokenStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _FlutterSecureStorageAdapter implements TokenStorage {
  final FlutterSecureStorage _inner;

  const _FlutterSecureStorageAdapter(this._inner);

  @override
  Future<String?> read(String key) => _inner.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _inner.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _inner.delete(key: key);
}
  
/// Signature for [FlutterWebAuth2.authenticate], injected for testing.
typedef WebAuthenticateFn = Future<String> Function({
  required String url,
  required String callbackUrlScheme,
});

/// Implements [AuthRepository] using Spotify's PKCE Authorization Code flow.
///
/// Tokens are persisted in encrypted storage and refreshed silently on expiry.
///
/// **Setup:** copy `lib/core/config/app_config.dart.example` →
/// `app_config.dart`, fill in [AppConfig.spotifyClientId], and register
/// `pullrequest://callback` as a Redirect URI in the Spotify Developer
/// Dashboard.
class SpotifyAuthService implements AuthRepository {
  static const _clientId = AppConfig.spotifyClientId;

  static const _redirectUri = 'pullrequest://callback';
  static const _authEndpoint = 'https://accounts.spotify.com/authorize';

  /// Scopes requested during authorization.
  /// Extend this set when new API features are added.
  static final _scopes = SpotifyScope.encode({
    SpotifyScope.playlistReadPrivate,
    SpotifyScope.playlistReadCollaborative,
  });
  static const _tokenEndpoint = 'https://accounts.spotify.com/api/token';

  // ── Secure storage keys ────────────────────────────────────────────────────
  static const _keyAccessToken = 'spotify_access_token';
  static const _keyRefreshToken = 'spotify_refresh_token';
  static const _keyExpiryMs = 'spotify_token_expiry_ms';

  final TokenStorage _storage;
  final http.Client _http;
  final WebAuthenticateFn _authenticate;

  SpotifyAuthService({
    TokenStorage? storage,
    http.Client? httpClient,
    WebAuthenticateFn? authenticate,
  })  : _storage = storage ??
            _FlutterSecureStorageAdapter(const FlutterSecureStorage()),
        _http = httpClient ?? http.Client(),
        _authenticate = authenticate ?? _flutterWebAuth2Authenticate;

  static Future<String> _flutterWebAuth2Authenticate({
    required String url,
    required String callbackUrlScheme,
  }) =>
      FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
      );

  // ── AuthRepository ─────────────────────────────────────────────────────────

  @override
  Future<AuthorizationResult> authorize(MusicPlatform platform) async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final state = _generateState();

    final uri = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'scope': _scopes,
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });

    // Launch browser — suspends until the user completes or cancels the flow.
    final String callbackUrl;
    try {
      callbackUrl = await _authenticate(
        url: uri.toString(),
        callbackUrlScheme: 'pullrequest',
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED' || e.code == 'cancelled') {
        return AuthorizationResult.failure(platform, 'Authorization cancelled');
      }
      throw AuthException('Browser authorization failed: ${e.message}');
    }

    final callbackUri = Uri.parse(callbackUrl);

    // Spotify returns an error query parameter on denial or failure.
    final error = callbackUri.queryParameters['error'];
    if (error != null) {
      return AuthorizationResult.failure(
          platform, _describeSpotifyError(error));
    }

    // State mismatch indicates a possible CSRF attack.
    if (callbackUri.queryParameters['state'] != state) {
      throw const AuthException(
          'Authorization failed: state mismatch — possible CSRF attack');
    }

    final code = callbackUri.queryParameters['code'];
    if (code == null) {
      throw const AuthException(
          'Authorization failed: no code returned in callback');
    }

    try {
      await _exchangeCodeForTokens(code, codeVerifier);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Token exchange failed: $e');
    }

    return AuthorizationResult.success(platform);
  }

  @override
  Future<bool> isAuthorized(String platformId) async {
    if (platformId != 'spotify') return false;

    final token = await _storage.read(_keyAccessToken);
    final expiryStr = await _storage.read(_keyExpiryMs);

    if (token == null || expiryStr == null) return false;

    final expiry =
        DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
    if (DateTime.now().isAfter(expiry)) {
      try {
        await _refreshTokens();
        return true;
      } on AuthException {
        return false;
      }
    }

    return true;
  }

  @override
  Future<void> revokeAuth(String platformId) async {
    await _storage.delete(_keyAccessToken);
    await _storage.delete(_keyRefreshToken);
    await _storage.delete(_keyExpiryMs);
  }

  // ── Public helper for future SpotifyPlaylistService ────────────────────────

  /// Returns a valid access token, silently refreshing if expired.
  ///
  /// Throws [AuthException] if no token is stored or the refresh fails.
  Future<String> getAccessToken() async {
    final token = await _storage.read(_keyAccessToken);
    final expiryStr = await _storage.read(_keyExpiryMs);

    if (token == null || expiryStr == null) {
      throw const AuthException(
          'Not authorized — call authorize() first');
    }

    final expiry =
        DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
    if (DateTime.now().isAfter(expiry)) {
      await _refreshTokens();
      final refreshed = await _storage.read(_keyAccessToken);
      if (refreshed == null) {
        throw const AuthException(
            'Token refresh completed but no token was stored');
      }
      return refreshed;
    }

    return token;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _exchangeCodeForTokens(
      String code, String codeVerifier) async {
    final response = await _http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
        'client_id': _clientId,
        'code_verifier': codeVerifier,
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        'Token exchange failed',
        code: response.statusCode.toString(),
      );
    }

    await _storeTokens(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> _refreshTokens() async {
    final refreshToken = await _storage.read(_keyRefreshToken);
    if (refreshToken == null) {
      throw const AuthException('No refresh token stored');
    }

    final response = await _http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': _clientId,
      },
    );

    if (response.statusCode != 200) {
      // Clear tokens on failed refresh — user must re-authorize.
      await revokeAuth('spotify');
      throw AuthException(
        'Session expired — please re-authorize',
        code: response.statusCode.toString(),
      );
    }

    await _storeTokens(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> _storeTokens(Map<String, dynamic> json) async {
    final accessToken = json['access_token'] as String;
    final expiresIn = json['expires_in'] as int; // seconds until expiry
    final newRefreshToken = json['refresh_token'] as String?;

    final expiryMs = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;

    await _storage.write(_keyAccessToken, accessToken);
    await _storage.write(_keyExpiryMs, expiryMs.toString());
    // Spotify may omit refresh_token on refresh responses — keep the old one.
    if (newRefreshToken != null) {
      await _storage.write(_keyRefreshToken, newRefreshToken);
    }
  }

  // ── PKCE helpers ───────────────────────────────────────────────────────────

  String _generateCodeVerifier() {
    final bytes =
        List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String codeVerifier) {
    final digest = sha256.convert(utf8.encode(codeVerifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  String _generateState() {
    final bytes =
        List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _describeSpotifyError(String error) => switch (error) {
        'access_denied' => 'Access denied — permission not granted to the app',
        _ => 'Spotify authorization error: $error',
      };
}
