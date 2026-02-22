import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_request/providers/auth_provider.dart';
import 'package:pull_request/providers/playlist_provider.dart';
import 'package:pull_request/screens/platform_authorization_screen.dart';
import 'package:pull_request/screens/platform_selection_screen.dart';
import 'package:pull_request/services/mock_auth_service.dart';
import 'package:pull_request/services/mock_playlist_service.dart';
import 'package:pull_request/services/platform_service.dart';
import 'package:pull_request/core/router/app_router.dart';

/// Builds a testable app with the full provider tree and a minimal router
/// that covers the platform-selection → authorization navigation path.
Widget _buildTestApp() {
  final router = GoRouter(
    initialLocation: AppRoutes.platformSelection,
    routes: [
      GoRoute(
        path: AppRoutes.platformSelection,
        builder: (_, _) => const PlatformSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.authorize,
        builder: (_, state) {
          final args = state.extra as AuthorizationArgs;
          return PlatformAuthorizationScreen(
            platform: args.platform,
            isSource: args.isSource,
          );
        },
      ),
    ],
  );

  return MultiProvider(
    providers: [
      Provider<PlatformService>(create: (_) => PlatformService()),
      ChangeNotifierProvider(
        create: (_) => AuthProvider(repository: MockAuthService()),
      ),
      ChangeNotifierProvider(
        create: (_) => PlaylistProvider(repository: MockPlaylistService()),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('PlatformSelectionScreen', () {
    testWidgets('renders all UI elements', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('PullRequest'), findsOneWidget);
      expect(find.text('FROM (Source)'), findsOneWidget);
      expect(find.text('TO (Destination)'), findsOneWidget);
      expect(find.text('Select Playlists'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('Select Playlists button is initially disabled', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Select Playlists'),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('can select source platform', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connect Platform').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spotify').last);
      await tester.pumpAndSettle();

      expect(find.text('Spotify'), findsWidgets);
    });

    testWidgets('can select destination platform', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connect Platform').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('YouTube Music').last);
      await tester.pumpAndSettle();

      expect(find.text('YouTube Music'), findsWidgets);
    });

    testWidgets('button is enabled when both platforms are selected', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

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

    testWidgets('navigates to authorization when Select Playlists is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

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

      expect(find.text('Connect to Spotify'), findsOneWidget);
    });
  });
}
