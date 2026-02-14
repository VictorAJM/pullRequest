import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/services/playlist_service.dart';

void main() {
  group('PlaylistService', () {
    late PlaylistService service;

    setUp(() {
      service = PlaylistService();
    });

    test('should throw ArgumentError for unknown platform ID', () async {
      expect(
        () => service.loadPlaylists('unknown_platform'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should return null for uncached platform', () {
      final playlists = service.getPlaylistsForPlatform('spotify');
      expect(playlists, null);
    });

    test('should clear cache when clearCache is called', () {
      // Initially cache should be empty
      expect(service.getPlaylistsForPlatform('spotify'), null);

      // Clear cache (should not throw even when empty)
      service.clearCache();

      // Check that cache is still empty
      expect(service.getPlaylistsForPlatform('spotify'), null);
    });

    // Note: Tests that require loading JSON assets are skipped in unit tests
    // as they require a Flutter test environment with asset loading.
    // These tests should be run as integration tests or widget tests.
    test('should recognize valid platform IDs', () {
      // Spotify should be recognized (will throw exception when loading, but not ArgumentError)
      expect(
        () => service.loadPlaylists('spotify'),
        throwsA(isNot(isA<ArgumentError>())),
      );

      // YouTube Music should be recognized
      expect(
        () => service.loadPlaylists('youtube_music'),
        throwsA(isNot(isA<ArgumentError>())),
      );
    });
  });
}
