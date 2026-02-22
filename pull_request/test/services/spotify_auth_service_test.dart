import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:pull_request/core/errors/app_exception.dart';
import 'package:pull_request/models/music_platform.dart';
import 'package:pull_request/services/spotify_auth_service.dart';

// ── Fake TokenStorage ─────────────────────────────────────────────────────────

class FakeTokenStorage implements TokenStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);

  bool containsKey(String key) => _store.containsKey(key);

  void clear() => _store.clear();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _spotify = MusicPlatform(
  id: 'spotify',
  name: 'Spotify',
  iconPath: 'assets/icons/spotify_icon.png',
  brandColor: Color(0xFF1DB954),
);

http.Response _tokenOkResponse({
  String accessToken = 'access_abc',
  String refreshToken = 'refresh_xyz',
  int expiresIn = 3600,
}) =>
    http.Response(
      jsonEncode({
        'access_token': accessToken,
        'token_type': 'Bearer',
        'expires_in': expiresIn,
        'refresh_token': refreshToken,
        'scope': 'playlist-read-private',
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

http.Response _errorResponse(int statusCode) =>
    http.Response('{"error":"invalid_grant"}', statusCode,
        headers: {'content-type': 'application/json'});

// Returns a WebAuthenticateFn that echoes back the correct state from the URL.
WebAuthenticateFn _successfulAuth({String code = 'auth_code_123'}) =>
    ({required String url, required String callbackUrlScheme}) async {
      final state = Uri.parse(url).queryParameters['state']!;
      return 'pullrequest://callback?code=$code&state=$state';
    };

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late FakeTokenStorage storage;

  setUp(() => storage = FakeTokenStorage());

  SpotifyAuthService build({
    WebAuthenticateFn? authenticate,
    http.Client? httpClient,
  }) =>
      SpotifyAuthService(
        storage: storage,
        httpClient: httpClient,
        authenticate: authenticate,
      );

  // ── authorize() ─────────────────────────────────────────────────────────────

  group('authorize()', () {
    test('success path stores tokens and returns authorized result', () async {
      final svc = build(
        authenticate: _successfulAuth(),
        httpClient: MockClient((_) async => _tokenOkResponse()),
      );

      final result = await svc.authorize(_spotify);

      expect(result.isAuthorized, isTrue);
      expect(result.platform, equals(_spotify));
      expect(storage.containsKey('spotify_access_token'), isTrue);
      expect(storage.containsKey('spotify_refresh_token'), isTrue);
      expect(storage.containsKey('spotify_token_expiry_ms'), isTrue);
    });

    test('user cancel returns failure without throwing', () async {
      final svc = build(
        authenticate: ({required url, required callbackUrlScheme}) async =>
            throw PlatformException(code: 'CANCELED'),
      );

      final result = await svc.authorize(_spotify);

      expect(result.isAuthorized, isFalse);
      expect(result.errorMessage, contains('cancelled'));
      expect(storage.containsKey('spotify_access_token'), isFalse);
    });

    test('Spotify access_denied returns failure with description', () async {
      final svc = build(
        authenticate: ({required url, required callbackUrlScheme}) async {
          final state = Uri.parse(url).queryParameters['state']!;
          return 'pullrequest://callback?error=access_denied&state=$state';
        },
      );

      final result = await svc.authorize(_spotify);

      expect(result.isAuthorized, isFalse);
      expect(result.errorMessage, contains('Access denied'));
    });

    test('state mismatch throws AuthException', () async {
      final svc = build(
        authenticate: ({required url, required callbackUrlScheme}) async =>
            'pullrequest://callback?code=code&state=tampered_state',
      );

      expect(
        () => svc.authorize(_spotify),
        throwsA(isA<AuthException>()),
      );
    });

    test('token exchange HTTP error throws AuthException', () async {
      final svc = build(
        authenticate: _successfulAuth(),
        httpClient: MockClient((_) async => _errorResponse(400)),
      );

      expect(
        () => svc.authorize(_spotify),
        throwsA(isA<AuthException>()),
      );
    });

    test('non-cancel PlatformException throws AuthException', () async {
      final svc = build(
        authenticate: ({required url, required callbackUrlScheme}) async =>
            throw PlatformException(code: 'NETWORK_ERROR'),
      );

      expect(
        () => svc.authorize(_spotify),
        throwsA(isA<AuthException>()),
      );
    });
  });

  // ── isAuthorized() ──────────────────────────────────────────────────────────

  group('isAuthorized()', () {
    test('returns false when no token stored', () async {
      expect(await build().isAuthorized('spotify'), isFalse);
    });

    test('returns false for unknown platformId', () async {
      expect(await build().isAuthorized('youtube_music'), isFalse);
    });

    test('returns true when valid unexpired token exists', () async {
      final expiryMs = DateTime.now()
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch;
      await storage.write('spotify_access_token', 'valid_token');
      await storage.write('spotify_refresh_token', 'refresh');
      await storage.write('spotify_token_expiry_ms', expiryMs.toString());

      expect(await build().isAuthorized('spotify'), isTrue);
    });

    test('returns true when token expired but refresh succeeds', () async {
      final expiredMs = DateTime.now()
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      await storage.write('spotify_access_token', 'old_token');
      await storage.write('spotify_refresh_token', 'refresh_token');
      await storage.write('spotify_token_expiry_ms', expiredMs.toString());

      final svc = build(
        httpClient: MockClient(
          (_) async => _tokenOkResponse(accessToken: 'new_token'),
        ),
      );

      expect(await svc.isAuthorized('spotify'), isTrue);
      expect(await storage.read('spotify_access_token'), equals('new_token'));
    });

    test('returns false when token expired and refresh fails', () async {
      final expiredMs = DateTime.now()
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      await storage.write('spotify_access_token', 'old_token');
      await storage.write('spotify_refresh_token', 'refresh_token');
      await storage.write('spotify_token_expiry_ms', expiredMs.toString());

      final svc = build(
        httpClient: MockClient((_) async => _errorResponse(401)),
      );

      expect(await svc.isAuthorized('spotify'), isFalse);
      // Tokens should be cleared after failed refresh.
      expect(storage.containsKey('spotify_access_token'), isFalse);
    });
  });

  // ── revokeAuth() ────────────────────────────────────────────────────────────

  group('revokeAuth()', () {
    test('clears all three storage keys', () async {
      await storage.write('spotify_access_token', 'token');
      await storage.write('spotify_refresh_token', 'refresh');
      await storage.write('spotify_token_expiry_ms', '999999999');

      await build().revokeAuth('spotify');

      expect(storage.containsKey('spotify_access_token'), isFalse);
      expect(storage.containsKey('spotify_refresh_token'), isFalse);
      expect(storage.containsKey('spotify_token_expiry_ms'), isFalse);
    });

    test('is a no-op when nothing is stored', () async {
      // Should not throw.
      await expectLater(build().revokeAuth('spotify'), completes);
    });
  });

  // ── getAccessToken() ────────────────────────────────────────────────────────

  group('getAccessToken()', () {
    test('returns stored token when not expired', () async {
      final expiryMs = DateTime.now()
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch;
      await storage.write('spotify_access_token', 'my_token');
      await storage.write('spotify_token_expiry_ms', expiryMs.toString());

      expect(await build().getAccessToken(), equals('my_token'));
    });

    test('throws AuthException when no token stored', () async {
      expect(
        () => build().getAccessToken(),
        throwsA(isA<AuthException>()),
      );
    });

    test('refreshes and returns new token when expired', () async {
      final expiredMs = DateTime.now()
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      await storage.write('spotify_access_token', 'old');
      await storage.write('spotify_refresh_token', 'refresh');
      await storage.write('spotify_token_expiry_ms', expiredMs.toString());

      final svc = build(
        httpClient: MockClient(
          (_) async => _tokenOkResponse(accessToken: 'refreshed_token'),
        ),
      );

      expect(await svc.getAccessToken(), equals('refreshed_token'));
    });
  });
}
