import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/models/platform.dart';

void main() {
  group('Platform', () {
    test('creates instance with required properties', () {
      const platform = Platform(
        id: 'test_id',
        name: 'Test Platform',
        iconPath: 'assets/test.png',
      );

      expect(platform.id, 'test_id');
      expect(platform.name, 'Test Platform');
      expect(platform.iconPath, 'assets/test.png');
    });

    test('equality works correctly for same platforms', () {
      const platform1 = Platform(
        id: 'spotify',
        name: 'Spotify',
        iconPath: 'assets/spotify.png',
      );

      const platform2 = Platform(
        id: 'spotify',
        name: 'Spotify',
        iconPath: 'assets/spotify.png',
      );

      expect(platform1, equals(platform2));
      expect(platform1.hashCode, equals(platform2.hashCode));
    });

    test('equality works correctly for different platforms', () {
      const platform1 = Platform(
        id: 'spotify',
        name: 'Spotify',
        iconPath: 'assets/spotify.png',
      );

      const platform2 = Platform(
        id: 'youtube',
        name: 'YouTube Music',
        iconPath: 'assets/youtube.png',
      );

      expect(platform1, isNot(equals(platform2)));
    });

    test('toString provides useful output', () {
      const platform = Platform(id: 'test', name: 'Test', iconPath: 'test.png');

      expect(
        platform.toString(),
        'Platform(id: test, name: Test, iconPath: test.png)',
      );
    });
  });
}
