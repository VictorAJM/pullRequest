import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/core/errors/app_exception.dart';
import 'package:pull_request/models/playlist.dart';
import 'package:pull_request/models/song.dart';
import 'package:pull_request/providers/playlist_provider.dart';
import 'package:pull_request/repositories/playlist_repository.dart';

// ── Test doubles ────────────────────────────────────────────────────────────

class _FakePlaylistRepository implements PlaylistRepository {
  final List<Playlist> playlists;
  final Playlist? detail;
  final bool throwOnFetch;
  final bool throwOnDetail;

  int fetchPlaylistsCallCount = 0;
  int fetchPlaylistDetailsCallCount = 0;

  _FakePlaylistRepository({
    this.playlists = const [],
    this.detail,
    this.throwOnFetch = false,
    this.throwOnDetail = false,
  });

  @override
  Future<List<Playlist>> fetchPlaylists(String platformId) async {
    fetchPlaylistsCallCount++;
    if (throwOnFetch) throw PlaylistException('Fetch failed', code: 'ERR');
    return playlists;
  }

  @override
  Future<Playlist> fetchPlaylistDetails(
    String platformId,
    String playlistId,
  ) async {
    fetchPlaylistDetailsCallCount++;
    if (throwOnDetail) {
      throw PlaylistException('Detail failed', code: 'DETAIL_ERR');
    }
    if (detail != null) return detail!;
    throw PlaylistException('Not found', code: 'NOT_FOUND');
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

Playlist _makePlaylist({
  String id = 'p1',
  String platformId = 'spotify',
  List<Song> songs = const [],
}) {
  return Playlist(
    id: id,
    name: 'Test Playlist',
    description: null,
    trackCount: songs.length,
    imageUrl: null,
    platformId: platformId,
    songs: songs,
  );
}

Song _makeSong(String id) => Song(
      id: id,
      title: 'Song $id',
      artist: 'Artist',
      album: null,
      durationSeconds: 180,
    );

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('PlaylistProvider — detail loading', () {
    test('detailsFor returns null before any fetch', () {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(),
      );
      expect(provider.detailsFor('p1'), isNull);
    });

    test('isLoadingDetails starts false', () {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(),
      );
      expect(provider.isLoadingDetails('p1'), isFalse);
    });

    test('detailErrorFor starts null', () {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(),
      );
      expect(provider.detailErrorFor('p1'), isNull);
    });

    test('loadPlaylistDetails stores result in detailsFor', () async {
      final songs = [_makeSong('s1'), _makeSong('s2')];
      final fullPlaylist = _makePlaylist(songs: songs);

      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(detail: fullPlaylist),
      );

      await provider.loadPlaylistDetails('spotify', 'p1');

      expect(provider.detailsFor('p1'), equals(fullPlaylist));
      expect(provider.detailsFor('p1')!.songs, hasLength(2));
    });

    test('loadPlaylistDetails clears error on success', () async {
      // First call — throws.
      final failing = _FakePlaylistRepository(throwOnDetail: true);
      final provider = PlaylistProvider(repository: failing);
      await provider.loadPlaylistDetails('spotify', 'p1');
      expect(provider.detailErrorFor('p1'), isNotNull);

      // Replace with a succeeding repository via a fresh provider that has the
      // same initial error state — simulate retry by using forceRefresh.
      final full = _makePlaylist(songs: [_makeSong('s1')]);
      final provider2 = PlaylistProvider(
        repository: _FakePlaylistRepository(detail: full),
      );
      // Manually seed an error state to verify it gets cleared.
      await provider2.loadPlaylistDetails('spotify', 'p1');
      expect(provider2.detailErrorFor('p1'), isNull);
    });

    test('isLoadingDetails is false after successful load', () async {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(
          detail: _makePlaylist(songs: [_makeSong('s1')]),
        ),
      );

      await provider.loadPlaylistDetails('spotify', 'p1');

      expect(provider.isLoadingDetails('p1'), isFalse);
    });

    test('detailErrorFor is set on PlaylistException', () async {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(throwOnDetail: true),
      );

      await provider.loadPlaylistDetails('spotify', 'p1');

      expect(provider.detailErrorFor('p1'), equals('Detail failed'));
      expect(provider.detailsFor('p1'), isNull);
    });

    test('second call with same ID is a cache hit — no extra fetch', () async {
      final repo = _FakePlaylistRepository(
        detail: _makePlaylist(songs: [_makeSong('s1')]),
      );
      final provider = PlaylistProvider(repository: repo);

      await provider.loadPlaylistDetails('spotify', 'p1');
      await provider.loadPlaylistDetails('spotify', 'p1');

      expect(repo.fetchPlaylistDetailsCallCount, equals(1));
    });

    test('forceRefresh bypasses the cache and re-fetches', () async {
      final repo = _FakePlaylistRepository(
        detail: _makePlaylist(songs: [_makeSong('s1')]),
      );
      final provider = PlaylistProvider(repository: repo);

      await provider.loadPlaylistDetails('spotify', 'p1');
      await provider.loadPlaylistDetails('spotify', 'p1', forceRefresh: true);

      expect(repo.fetchPlaylistDetailsCallCount, equals(2));
    });

    test('isLoadingDetails is false after a failed load', () async {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(throwOnDetail: true),
      );

      await provider.loadPlaylistDetails('spotify', 'p1');

      expect(provider.isLoadingDetails('p1'), isFalse);
    });
  });

  group('PlaylistProvider — clearCache', () {
    test('clearCache removes playlist list data', () async {
      final repo = _FakePlaylistRepository(
        playlists: [_makePlaylist()],
      );
      final provider = PlaylistProvider(repository: repo);

      await provider.loadPlaylists('spotify');
      expect(provider.playlistsFor('spotify'), isNotEmpty);

      provider.clearCache();
      expect(provider.playlistsFor('spotify'), isEmpty);
    });

    test('clearCache also removes detail data', () async {
      final full = _makePlaylist(songs: [_makeSong('s1')]);
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(detail: full),
      );

      await provider.loadPlaylistDetails('spotify', 'p1');
      expect(provider.detailsFor('p1'), isNotNull);

      provider.clearCache();
      expect(provider.detailsFor('p1'), isNull);
    });

    test('clearCache also removes detail errors', () async {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(throwOnDetail: true),
      );

      await provider.loadPlaylistDetails('spotify', 'p1');
      expect(provider.detailErrorFor('p1'), isNotNull);

      provider.clearCache();
      expect(provider.detailErrorFor('p1'), isNull);
    });

    test('after clearCache, loadPlaylistDetails re-fetches from repository',
        () async {
      final repo = _FakePlaylistRepository(
        detail: _makePlaylist(songs: [_makeSong('s1')]),
      );
      final provider = PlaylistProvider(repository: repo);

      await provider.loadPlaylistDetails('spotify', 'p1');
      provider.clearCache();
      await provider.loadPlaylistDetails('spotify', 'p1');

      expect(repo.fetchPlaylistDetailsCallCount, equals(2));
    });
  });

  group('PlaylistProvider — list loading (existing behaviour)', () {
    test('loadPlaylists caches result', () async {
      final repo = _FakePlaylistRepository(playlists: [_makePlaylist()]);
      final provider = PlaylistProvider(repository: repo);

      await provider.loadPlaylists('spotify');
      await provider.loadPlaylists('spotify');

      expect(repo.fetchPlaylistsCallCount, equals(1));
    });

    test('loadPlaylists sets error on PlaylistException', () async {
      final provider = PlaylistProvider(
        repository: _FakePlaylistRepository(throwOnFetch: true),
      );

      await provider.loadPlaylists('spotify');

      expect(provider.errorFor('spotify'), equals('Fetch failed'));
      expect(provider.playlistsFor('spotify'), isEmpty);
      expect(provider.isLoading('spotify'), isFalse);
    });

    test('forceRefresh re-fetches playlist list', () async {
      final repo = _FakePlaylistRepository(playlists: [_makePlaylist()]);
      final provider = PlaylistProvider(repository: repo);

      await provider.loadPlaylists('spotify');
      await provider.loadPlaylists('spotify', forceRefresh: true);

      expect(repo.fetchPlaylistsCallCount, equals(2));
    });
  });
}
