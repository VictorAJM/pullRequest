import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/models/music_platform.dart';

void main() {
  group('MusicPlatform', () {
    const platform = MusicPlatform(
      id: 'test_id',
      name: 'Test Platform',
      iconPath: 'assets/test.png',
      brandColor: Color(0xFF000000),
    );

    test('creates instance with required properties', () {
      expect(platform.id, 'test_id');
      expect(platform.name, 'Test Platform');
      expect(platform.iconPath, 'assets/test.png');
      expect(platform.brandColor, const Color(0xFF000000));
      expect(platform.oauthClientId, isNull);
      expect(platform.scopes, isEmpty);
    });

    test('creates instance with optional properties', () {
      const p = MusicPlatform(
        id: 'spotify',
        name: 'Spotify',
        iconPath: 'assets/spotify.png',
        brandColor: Color(0xFF1DB954),
        oauthClientId: 'client-123',
        scopes: ['playlist-read-private'],
      );

      expect(p.oauthClientId, 'client-123');
      expect(p.scopes, ['playlist-read-private']);
    });

    test('equality is based on id only', () {
      const p1 = MusicPlatform(
        id: 'spotify',
        name: 'Spotify',
        iconPath: 'assets/spotify.png',
        brandColor: Color(0xFF1DB954),
      );
      const p2 = MusicPlatform(
        id: 'spotify',
        name: 'Spotify (different name)',
        iconPath: 'assets/other.png',
        brandColor: Color(0xFF000000),
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('platforms with different ids are not equal', () {
      const p1 = MusicPlatform(
        id: 'spotify',
        name: 'Spotify',
        iconPath: 'assets/spotify.png',
        brandColor: Color(0xFF1DB954),
      );
      const p2 = MusicPlatform(
        id: 'youtube_music',
        name: 'YouTube Music',
        iconPath: 'assets/youtube.png',
        brandColor: Color(0xFFFF0000),
      );

      expect(p1, isNot(equals(p2)));
    });

    test('toString provides useful output', () {
      expect(platform.toString(), 'MusicPlatform(id: test_id, name: Test Platform)');
    });
  });
}
