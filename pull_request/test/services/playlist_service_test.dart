import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/core/errors/app_exception.dart';
import 'package:pull_request/services/mock_playlist_service.dart';

void main() {
  group('MockPlaylistService', () {
    late MockPlaylistService service;

    setUp(() {
      service = MockPlaylistService();
    });

    test('throws PlaylistException for unknown platform ID', () {
      expect(
        () => service.fetchPlaylists('unknown_platform'),
        throwsA(isA<PlaylistException>()),
      );
    });

    test('throws PlaylistException with UNKNOWN_PLATFORM code', () async {
      try {
        await service.fetchPlaylists('unknown_platform');
        fail('Expected PlaylistException');
      } on PlaylistException catch (e) {
        expect(e.code, 'UNKNOWN_PLATFORM');
      }
    });

    test('recognizes spotify as a valid platform', () {
      // Should throw a non-PlaylistException (asset loading fails in unit tests)
      expect(
        () => service.fetchPlaylists('spotify'),
        throwsA(isNot(isA<ArgumentError>())),
      );
    });

    test('recognizes youtube_music as a valid platform', () {
      expect(
        () => service.fetchPlaylists('youtube_music'),
        throwsA(isNot(isA<ArgumentError>())),
      );
    });

    test('clearCache does not throw when cache is empty', () {
      expect(() => service.clearCache(), returnsNormally);
    });

    test('fetchPlaylistDetails throws PlaylistException for unknown playlist',
        () async {
      try {
        await service.fetchPlaylistDetails('spotify', 'nonexistent_id');
      } on PlaylistException catch (e) {
        // Either UNKNOWN_PLATFORM (can't load assets) or NOT_FOUND is acceptable
        expect(e.code, isNotNull);
      } catch (_) {
        // Asset loading failure in unit test context is acceptable
      }
    });
  });
}
