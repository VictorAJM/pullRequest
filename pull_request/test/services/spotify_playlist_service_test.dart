import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:pull_request/core/errors/app_exception.dart';
import 'package:pull_request/services/spotify_auth_service.dart';
import 'package:pull_request/services/spotify_playlist_service.dart';

// ── Fake TokenStorage ─────────────────────────────────────────────────────────

class FakeTokenStorage implements TokenStorage {
  final Map<String, String> _store;

  FakeTokenStorage([Map<String, String>? initial])
      : _store = Map.of(initial ?? {});

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

Map<String, dynamic> _playlistItem({
  String id = 'pl1',
  String name = 'My Playlist',
  String description = 'A playlist',
  int total = 2,
  String? imageUrl = 'https://example.com/img.jpg',
}) =>
    {
      'id': id,
      'name': name,
      'description': description,
      'tracks': {'total': total},
      'images': imageUrl != null ? [{'url': imageUrl}] : [],
    };

Map<String, dynamic> _trackItem({
  String id = 't1',
  String name = 'Track One',
  String artist = 'Artist A',
  String album = 'Album X',
  int durationMs = 210000,
  bool isLocal = false,
}) =>
    {
      'track': {
        'id': id,
        'name': name,
        'artists': [
          {'name': artist}
        ],
        'album': {'name': album},
        'duration_ms': durationMs,
        'is_local': isLocal,
      },
    };

http.Response _jsonResponse(Object body, [int statusCode = 200]) =>
    http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json'},
    );

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Builds a [SpotifyAuthService] pre-loaded with a valid (non-expired) token.
SpotifyAuthService _stubAuth({String token = 'fake_token'}) {
  final expiryMs = DateTime.now()
      .add(const Duration(hours: 1))
      .millisecondsSinceEpoch;
  return SpotifyAuthService(
    storage: FakeTokenStorage({
      'spotify_access_token': token,
      'spotify_token_expiry_ms': expiryMs.toString(),
    }),
  );
}

/// Builds a [SpotifyAuthService] with NO stored token (simulates not authorized).
SpotifyAuthService _noTokenAuth() =>
    SpotifyAuthService(storage: FakeTokenStorage());

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── fetchPlaylists ───────────────────────────────────────────────────────────

  group('fetchPlaylists()', () {
    test('single page returns mapped playlists', () async {
      final client = MockClient((_) async => _jsonResponse({
            'items': [_playlistItem(id: 'p1', name: 'Chill'), _playlistItem(id: 'p2', name: 'Hype')],
            'next': null,
          }));

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylists('spotify');

      expect(result, hasLength(2));
      expect(result[0].id, 'p1');
      expect(result[0].name, 'Chill');
      expect(result[0].platformId, 'spotify');
      expect(result[1].id, 'p2');
    });

    test('paginates across multiple pages and merges results', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return _jsonResponse({
            'items': [_playlistItem(id: 'p1', name: 'Page 1 Playlist')],
            'next': 'https://api.spotify.com/v1/me/playlists?limit=50&offset=50',
          });
        } else {
          return _jsonResponse({
            'items': [_playlistItem(id: 'p2', name: 'Page 2 Playlist')],
            'next': null,
          });
        }
      });

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylists('spotify');

      expect(result, hasLength(2));
      expect(result[0].id, 'p1');
      expect(result[1].id, 'p2');
      expect(callCount, 2);
    });

    test('maps image URL correctly', () async {
      final client = MockClient((_) async => _jsonResponse({
            'items': [_playlistItem(imageUrl: 'https://img.example.com/cover.jpg')],
            'next': null,
          }));

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylists('spotify');

      expect(result[0].imageUrl, 'https://img.example.com/cover.jpg');
    });

    test('null imageUrl when images list is empty', () async {
      final client = MockClient((_) async => _jsonResponse({
            'items': [_playlistItem(imageUrl: null)],
            'next': null,
          }));

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylists('spotify');

      expect(result[0].imageUrl, isNull);
    });

    test('empty description becomes null', () async {
      final client = MockClient((_) async => _jsonResponse({
            'items': [_playlistItem(description: '')],
            'next': null,
          }));

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylists('spotify');

      expect(result[0].description, isNull);
    });

    test('401 response throws PlaylistException with code 401', () async {
      final client = MockClient((_) async => _jsonResponse({'error': 'Unauthorized'}, 401));

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);

      expect(
        () => svc.fetchPlaylists('spotify'),
        throwsA(
          isA<PlaylistException>().having((e) => e.code, 'code', '401'),
        ),
      );
    });

    test('non-200 response throws PlaylistException with status code', () async {
      final client = MockClient((_) async => _jsonResponse({'error': 'Server Error'}, 503));

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);

      expect(
        () => svc.fetchPlaylists('spotify'),
        throwsA(
          isA<PlaylistException>().having((e) => e.code, 'code', '503'),
        ),
      );
    });

    test('missing token throws PlaylistException', () async {
      final svc = SpotifyPlaylistService(
        auth: _noTokenAuth(),
        httpClient: MockClient((_) async => throw StateError('should not call')),
      );

      expect(
        () => svc.fetchPlaylists('spotify'),
        throwsA(isA<PlaylistException>()),
      );
    });
  });

  // ── fetchPlaylistDetails ─────────────────────────────────────────────────────

  group('fetchPlaylistDetails()', () {
    test('returns playlist with populated songs', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          // metadata request
          return _jsonResponse(_playlistItem(id: 'pl1', name: 'Workout', total: 2));
        } else {
          // tracks request
          return _jsonResponse({
            'items': [
              _trackItem(id: 't1', name: 'Run', artist: 'Runner', album: 'Cardio', durationMs: 180000),
              _trackItem(id: 't2', name: 'Sprint', artist: 'Pacer', album: 'Cardio', durationMs: 120000),
            ],
            'next': null,
          });
        }
      });

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylistDetails('spotify', 'pl1');

      expect(result.id, 'pl1');
      expect(result.songs, hasLength(2));
      expect(result.songs[0].id, 't1');
      expect(result.songs[0].title, 'Run');
      expect(result.songs[0].artist, 'Runner');
      expect(result.songs[0].album, 'Cardio');
      expect(result.songs[0].durationSeconds, 180);
      expect(result.songs[1].id, 't2');
    });

    test('skips null track objects (deleted/unavailable tracks)', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return _jsonResponse(_playlistItem(id: 'pl1', total: 1));
        } else {
          return _jsonResponse({
            'items': [
              {'track': null},
              _trackItem(id: 't1', name: 'Valid Track'),
            ],
            'next': null,
          });
        }
      });

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylistDetails('spotify', 'pl1');

      expect(result.songs, hasLength(1));
      expect(result.songs[0].id, 't1');
    });

    test('skips local tracks (is_local == true)', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return _jsonResponse(_playlistItem(id: 'pl1', total: 1));
        } else {
          return _jsonResponse({
            'items': [
              _trackItem(id: 'local1', name: 'Local File', isLocal: true),
              _trackItem(id: 't1', name: 'Streaming Track'),
            ],
            'next': null,
          });
        }
      });

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylistDetails('spotify', 'pl1');

      expect(result.songs, hasLength(1));
      expect(result.songs[0].id, 't1');
    });

    test('paginates tracks across multiple pages', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return _jsonResponse(_playlistItem(id: 'pl1', total: 2));
        } else if (callCount == 2) {
          return _jsonResponse({
            'items': [_trackItem(id: 't1', name: 'First')],
            'next': 'https://api.spotify.com/v1/playlists/pl1/tracks?limit=100&offset=100',
          });
        } else {
          return _jsonResponse({
            'items': [_trackItem(id: 't2', name: 'Second')],
            'next': null,
          });
        }
      });

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylistDetails('spotify', 'pl1');

      expect(result.songs, hasLength(2));
      expect(result.songs[0].id, 't1');
      expect(result.songs[1].id, 't2');
    });

    test('artist fallback to Unknown Artist when artists list is empty', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return _jsonResponse(_playlistItem(id: 'pl1', total: 1));
        } else {
          return _jsonResponse({
            'items': [
              {
                'track': {
                  'id': 't1',
                  'name': 'Mystery Track',
                  'artists': [],
                  'album': {'name': 'Unknown Album'},
                  'duration_ms': 60000,
                  'is_local': false,
                },
              }
            ],
            'next': null,
          });
        }
      });

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);
      final result = await svc.fetchPlaylistDetails('spotify', 'pl1');

      expect(result.songs[0].artist, 'Unknown Artist');
    });

    test('401 on metadata throws PlaylistException with code 401', () async {
      final client = MockClient((_) async => _jsonResponse({'error': 'Unauthorized'}, 401));

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);

      expect(
        () => svc.fetchPlaylistDetails('spotify', 'pl1'),
        throwsA(
          isA<PlaylistException>().having((e) => e.code, 'code', '401'),
        ),
      );
    });

    test('non-200 on tracks throws PlaylistException', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return _jsonResponse(_playlistItem(id: 'pl1', total: 1));
        } else {
          return _jsonResponse({'error': 'Not Found'}, 404);
        }
      });

      final svc = SpotifyPlaylistService(auth: _stubAuth(), httpClient: client);

      expect(
        () => svc.fetchPlaylistDetails('spotify', 'pl1'),
        throwsA(
          isA<PlaylistException>().having((e) => e.code, 'code', '404'),
        ),
      );
    });
  });
}
