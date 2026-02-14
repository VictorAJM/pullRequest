import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/models/playlist.dart';

void main() {
  group('Playlist', () {
    test('should create a Playlist instance with all properties', () {
      const playlist = Playlist(
        id: 'test_1',
        name: 'Test Playlist',
        description: 'A test playlist',
        trackCount: 10,
        imageUrl: 'https://example.com/image.png',
        platformId: 'spotify',
      );

      expect(playlist.id, 'test_1');
      expect(playlist.name, 'Test Playlist');
      expect(playlist.description, 'A test playlist');
      expect(playlist.trackCount, 10);
      expect(playlist.imageUrl, 'https://example.com/image.png');
      expect(playlist.platformId, 'spotify');
    });

    test('should create a Playlist with optional fields as null', () {
      const playlist = Playlist(
        id: 'test_2',
        name: 'Minimal Playlist',
        trackCount: 5,
        platformId: 'youtube_music',
      );

      expect(playlist.id, 'test_2');
      expect(playlist.name, 'Minimal Playlist');
      expect(playlist.description, null);
      expect(playlist.trackCount, 5);
      expect(playlist.imageUrl, null);
      expect(playlist.platformId, 'youtube_music');
    });

    test('should create Playlist from JSON', () {
      final json = {
        'id': 'json_1',
        'name': 'JSON Playlist',
        'description': 'Created from JSON',
        'trackCount': 15,
        'imageUrl': 'https://example.com/json.png',
        'platformId': 'spotify',
      };

      final playlist = Playlist.fromJson(json);

      expect(playlist.id, 'json_1');
      expect(playlist.name, 'JSON Playlist');
      expect(playlist.description, 'Created from JSON');
      expect(playlist.trackCount, 15);
      expect(playlist.imageUrl, 'https://example.com/json.png');
      expect(playlist.platformId, 'spotify');
    });

    test('should create Playlist from JSON with null optional fields', () {
      final json = {
        'id': 'json_2',
        'name': 'Minimal JSON Playlist',
        'description': null,
        'trackCount': 8,
        'imageUrl': null,
        'platformId': 'youtube_music',
      };

      final playlist = Playlist.fromJson(json);

      expect(playlist.id, 'json_2');
      expect(playlist.name, 'Minimal JSON Playlist');
      expect(playlist.description, null);
      expect(playlist.trackCount, 8);
      expect(playlist.imageUrl, null);
      expect(playlist.platformId, 'youtube_music');
    });

    test('should convert Playlist to JSON', () {
      const playlist = Playlist(
        id: 'test_3',
        name: 'To JSON Playlist',
        description: 'Will be converted to JSON',
        trackCount: 20,
        imageUrl: 'https://example.com/tojson.png',
        platformId: 'spotify',
      );

      final json = playlist.toJson();

      expect(json['id'], 'test_3');
      expect(json['name'], 'To JSON Playlist');
      expect(json['description'], 'Will be converted to JSON');
      expect(json['trackCount'], 20);
      expect(json['imageUrl'], 'https://example.com/tojson.png');
      expect(json['platformId'], 'spotify');
    });

    test('should handle JSON round-trip conversion', () {
      const original = Playlist(
        id: 'roundtrip_1',
        name: 'Round Trip Playlist',
        description: 'Testing round trip',
        trackCount: 12,
        imageUrl: 'https://example.com/roundtrip.png',
        platformId: 'youtube_music',
      );

      final json = original.toJson();
      final restored = Playlist.fromJson(json);

      expect(restored, original);
    });

    test('should compare two identical Playlists as equal', () {
      const playlist1 = Playlist(
        id: 'equal_1',
        name: 'Equal Playlist',
        description: 'Testing equality',
        trackCount: 25,
        imageUrl: 'https://example.com/equal.png',
        platformId: 'spotify',
      );

      const playlist2 = Playlist(
        id: 'equal_1',
        name: 'Equal Playlist',
        description: 'Testing equality',
        trackCount: 25,
        imageUrl: 'https://example.com/equal.png',
        platformId: 'spotify',
      );

      expect(playlist1, playlist2);
      expect(playlist1.hashCode, playlist2.hashCode);
    });

    test('should compare two different Playlists as not equal', () {
      const playlist1 = Playlist(
        id: 'diff_1',
        name: 'Different Playlist 1',
        trackCount: 10,
        platformId: 'spotify',
      );

      const playlist2 = Playlist(
        id: 'diff_2',
        name: 'Different Playlist 2',
        trackCount: 20,
        platformId: 'youtube_music',
      );

      expect(playlist1, isNot(playlist2));
    });

    test('should generate correct toString output', () {
      const playlist = Playlist(
        id: 'string_1',
        name: 'String Playlist',
        description: 'Testing toString',
        trackCount: 30,
        platformId: 'spotify',
      );

      final string = playlist.toString();

      expect(string, contains('string_1'));
      expect(string, contains('String Playlist'));
      expect(string, contains('30'));
      expect(string, contains('spotify'));
    });
  });
}
