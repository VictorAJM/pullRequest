import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/models/music_platform.dart';
import 'package:pull_request/models/authorization_result.dart';

void main() {
  group('AuthorizationResult', () {
    const testPlatform = MusicPlatform(
      id: 'spotify',
      name: 'Spotify',
      iconPath: 'assets/test.png',
      brandColor: Color(0xFF1DB954),
    );

    test('creates successful result', () {
      final result = AuthorizationResult.success(testPlatform);

      expect(result.isAuthorized, isTrue);
      expect(result.platform, testPlatform);
      expect(result.errorMessage, isNull);
    });

    test('creates failure result with error message', () {
      final result = AuthorizationResult.failure(
        testPlatform,
        'Connection timeout',
      );

      expect(result.isAuthorized, isFalse);
      expect(result.platform, testPlatform);
      expect(result.errorMessage, 'Connection timeout');
    });

    test('can create result with constructor', () {
      const result = AuthorizationResult(
        isAuthorized: true,
        platform: testPlatform,
      );

      expect(result.isAuthorized, isTrue);
      expect(result.platform, testPlatform);
      expect(result.errorMessage, isNull);
    });
  });
}
