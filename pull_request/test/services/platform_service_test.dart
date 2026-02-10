import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/services/platform_service.dart';

void main() {
  group('PlatformService', () {
    late PlatformService service;

    setUp(() {
      service = PlatformService();
    });

    test('returns list of available platforms', () {
      final platforms = service.getAvailablePlatforms();

      expect(platforms, isNotEmpty);
      expect(platforms.length, greaterThanOrEqualTo(2));
    });

    test('returned platforms have valid data', () {
      final platforms = service.getAvailablePlatforms();

      for (final platform in platforms) {
        expect(platform.id, isNotEmpty);
        expect(platform.name, isNotEmpty);
        expect(platform.iconPath, isNotEmpty);
      }
    });

    test('includes Spotify platform', () {
      final platforms = service.getAvailablePlatforms();
      final spotify = platforms.firstWhere((p) => p.id == 'spotify');

      expect(spotify.name, 'Spotify');
      expect(spotify.iconPath, contains('spotify'));
    });

    test('includes YouTube Music platform', () {
      final platforms = service.getAvailablePlatforms();
      final youtube = platforms.firstWhere((p) => p.id == 'youtube_music');

      expect(youtube.name, 'YouTube Music');
      expect(youtube.iconPath, contains('youtube'));
    });

    test('getPlatformById returns correct platform', () {
      final platform = service.getPlatformById('spotify');

      expect(platform, isNotNull);
      expect(platform!.id, 'spotify');
      expect(platform.name, 'Spotify');
    });

    test('getPlatformById returns null for invalid id', () {
      final platform = service.getPlatformById('invalid_id');

      expect(platform, isNull);
    });

    test('returned list is unmodifiable', () {
      final platforms = service.getAvailablePlatforms();

      expect(() => platforms.add(platforms.first), throwsUnsupportedError);
    });
  });
}
