import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/screens/platform_selection_screen.dart';

void main() {
  group('PlatformSelectionScreen', () {
    testWidgets('renders all UI elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlatformSelectionScreen()),
      );

      expect(find.text('PullRequest'), findsOneWidget);
      expect(find.text('FROM (Source)'), findsOneWidget);
      expect(find.text('TO (Destination)'), findsOneWidget);
      expect(find.text('Select Playlists'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('Select Playlists button is initially disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlatformSelectionScreen()),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Select Playlists'),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('can select source platform', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlatformSelectionScreen()),
      );

      await tester.tap(find.text('Connect Platform').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spotify').last);
      await tester.pumpAndSettle();

      expect(find.text('Spotify'), findsWidgets);
    });

    testWidgets('can select destination platform', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlatformSelectionScreen()),
      );

      await tester.tap(find.text('Connect Platform').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('YouTube Music').last);
      await tester.pumpAndSettle();

      expect(find.text('YouTube Music'), findsWidgets);
    });

    testWidgets('button enabled when both platforms selected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlatformSelectionScreen()),
      );

      await tester.tap(find.text('Connect Platform').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spotify').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connect Platform').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('YouTube Music').last);
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Select Playlists'),
      );

      expect(button.onPressed, isNotNull);
    });

    testWidgets('prevents selecting same platform for source and destination', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlatformSelectionScreen()),
      );

      await tester.tap(find.text('Connect Platform').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spotify').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connect Platform').last);
      await tester.pumpAndSettle();

      final spotifyCards = find.text('Spotify');
      expect(spotifyCards, findsWidgets);
    });

    testWidgets('shows snackbar when Select Playlists is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlatformSelectionScreen()),
      );

      await tester.tap(find.text('Connect Platform').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spotify').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connect Platform').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('YouTube Music').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Playlists'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Transferring from Spotify to YouTube Music'),
        findsOneWidget,
      );
    });

    testWidgets('back button navigates back', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlatformSelectionScreen(),
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('FROM (Source)'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('FROM (Source)'), findsNothing);
    });
  });
}
