import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/models/song.dart';

void main() {
  group('Song', () {
    test('should create a Song instance with all properties', () {
      const song = Song(
        id: 'test_1',
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        durationSeconds: 180,
      );

      expect(song.id, 'test_1');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.album, 'Test Album');
      expect(song.durationSeconds, 180);
    });

    test('should create a Song with optional album as null', () {
      const song = Song(
        id: 'test_2',
        title: 'No Album Song',
        artist: 'Artist Name',
        durationSeconds: 240,
      );

      expect(song.id, 'test_2');
      expect(song.title, 'No Album Song');
      expect(song.artist, 'Artist Name');
      expect(song.album, null);
      expect(song.durationSeconds, 240);
    });

    test('should create Song from JSON', () {
      final json = {
        'id': 'json_1',
        'title': 'JSON Song',
        'artist': 'JSON Artist',
        'album': 'JSON Album',
        'durationSeconds': 200,
      };

      final song = Song.fromJson(json);

      expect(song.id, 'json_1');
      expect(song.title, 'JSON Song');
      expect(song.artist, 'JSON Artist');
      expect(song.album, 'JSON Album');
      expect(song.durationSeconds, 200);
    });

    test('should create Song from JSON with null album', () {
      final json = {
        'id': 'json_2',
        'title': 'Minimal JSON Song',
        'artist': 'Minimal Artist',
        'album': null,
        'durationSeconds': 150,
      };

      final song = Song.fromJson(json);

      expect(song.id, 'json_2');
      expect(song.title, 'Minimal JSON Song');
      expect(song.artist, 'Minimal Artist');
      expect(song.album, null);
      expect(song.durationSeconds, 150);
    });

    test('should convert Song to JSON', () {
      const song = Song(
        id: 'test_3',
        title: 'To JSON Song',
        artist: 'To JSON Artist',
        album: 'To JSON Album',
        durationSeconds: 220,
      );

      final json = song.toJson();

      expect(json['id'], 'test_3');
      expect(json['title'], 'To JSON Song');
      expect(json['artist'], 'To JSON Artist');
      expect(json['album'], 'To JSON Album');
      expect(json['durationSeconds'], 220);
    });

    test('should format duration correctly', () {
      const song1 = Song(
        id: 'test_4',
        title: 'Short Song',
        artist: 'Artist',
        durationSeconds: 125, // 2:05
      );

      const song2 = Song(
        id: 'test_5',
        title: 'Long Song',
        artist: 'Artist',
        durationSeconds: 305, // 5:05
      );

      expect(song1.formattedDuration, '2:05');
      expect(song2.formattedDuration, '5:05');
    });

    test('should pad seconds with zero when needed', () {
      const song = Song(
        id: 'test_6',
        title: 'Padding Test',
        artist: 'Artist',
        durationSeconds: 183, // 3:03
      );

      expect(song.formattedDuration, '3:03');
    });

    test('should handle JSON round-trip conversion', () {
      const original = Song(
        id: 'roundtrip_1',
        title: 'Round Trip Song',
        artist: 'Round Trip Artist',
        album: 'Round Trip Album',
        durationSeconds: 195,
      );

      final json = original.toJson();
      final restored = Song.fromJson(json);

      expect(restored, original);
    });

    test('should compare two identical Songs as equal', () {
      const song1 = Song(
        id: 'equal_1',
        title: 'Equal Song',
        artist: 'Equal Artist',
        album: 'Equal Album',
        durationSeconds: 210,
      );

      const song2 = Song(
        id: 'equal_1',
        title: 'Equal Song',
        artist: 'Equal Artist',
        album: 'Equal Album',
        durationSeconds: 210,
      );

      expect(song1, song2);
      expect(song1.hashCode, song2.hashCode);
    });

    test('should compare two different Songs as not equal', () {
      const song1 = Song(
        id: 'diff_1',
        title: 'Different Song 1',
        artist: 'Artist 1',
        durationSeconds: 180,
      );

      const song2 = Song(
        id: 'diff_2',
        title: 'Different Song 2',
        artist: 'Artist 2',
        durationSeconds: 240,
      );

      expect(song1, isNot(song2));
    });

    test('should generate correct toString output', () {
      const song = Song(
        id: 'string_1',
        title: 'String Song',
        artist: 'String Artist',
        durationSeconds: 200,
      );

      final string = song.toString();

      expect(string, contains('string_1'));
      expect(string, contains('String Song'));
      expect(string, contains('String Artist'));
      expect(string, contains('3:20'));
    });
  });
}
