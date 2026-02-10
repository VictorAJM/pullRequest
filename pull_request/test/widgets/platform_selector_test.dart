import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/models/platform.dart';
import 'package:pull_request/widgets/platform_selector.dart';

void main() {
  group('PlatformSelector', () {
    const testPlatforms = [
      Platform(
        id: 'spotify',
        name: 'Spotify',
        iconPath: 'assets/icons/spotify_icon.png',
      ),
      Platform(
        id: 'youtube',
        name: 'YouTube Music',
        iconPath: 'assets/icons/youtube_music_icon.png',
      ),
    ];

    testWidgets('displays title correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformSelector(
              title: 'FROM (Source)',
              selectedPlatform: null,
              availablePlatforms: testPlatforms,
              disabledPlatformIds: const [],
              onPlatformSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('FROM (Source)'), findsOneWidget);
    });

    testWidgets('shows Connect Platform button when no platform selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformSelector(
              title: 'FROM (Source)',
              selectedPlatform: null,
              availablePlatforms: testPlatforms,
              disabledPlatformIds: const [],
              onPlatformSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Connect Platform'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('shows selected platform when platform is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformSelector(
              title: 'FROM (Source)',
              selectedPlatform: testPlatforms[0],
              availablePlatforms: testPlatforms,
              disabledPlatformIds: const [],
              onPlatformSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Spotify'), findsOneWidget);
    });

    testWidgets('opens bottom sheet when Connect Platform is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformSelector(
              title: 'FROM (Source)',
              selectedPlatform: null,
              availablePlatforms: testPlatforms,
              disabledPlatformIds: const [],
              onPlatformSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Connect Platform'));
      await tester.pumpAndSettle();

      expect(find.text('Select Platform'), findsOneWidget);
    });

    testWidgets('displays all available platforms in bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformSelector(
              title: 'FROM (Source)',
              selectedPlatform: null,
              availablePlatforms: testPlatforms,
              disabledPlatformIds: const [],
              onPlatformSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Connect Platform'));
      await tester.pumpAndSettle();

      expect(find.text('Spotify'), findsOneWidget);
      expect(find.text('YouTube Music'), findsOneWidget);
    });

    testWidgets('calls onPlatformSelected when platform is tapped', (
      tester,
    ) async {
      Platform? selectedPlatform;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformSelector(
              title: 'FROM (Source)',
              selectedPlatform: null,
              availablePlatforms: testPlatforms,
              disabledPlatformIds: const [],
              onPlatformSelected: (platform) => selectedPlatform = platform,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Connect Platform'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spotify').last);
      await tester.pumpAndSettle();

      expect(selectedPlatform, isNotNull);
      expect(selectedPlatform!.id, 'spotify');
    });

    testWidgets('closes bottom sheet after platform selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformSelector(
              title: 'FROM (Source)',
              selectedPlatform: null,
              availablePlatforms: testPlatforms,
              disabledPlatformIds: const [],
              onPlatformSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Connect Platform'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spotify').last);
      await tester.pumpAndSettle();

      expect(find.text('Select Platform'), findsNothing);
    });
  });
}
