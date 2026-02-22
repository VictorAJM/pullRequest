import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_request/models/authorization_state.dart';
import 'package:pull_request/models/music_platform.dart';
import 'package:pull_request/providers/auth_provider.dart';
import 'package:pull_request/screens/platform_authorization_screen.dart';
import 'package:pull_request/services/mock_auth_service.dart';

/// Builds a testable app wrapping [PlatformAuthorizationScreen] with the
/// required [AuthProvider] and a minimal GoRouter.
Widget _buildTestApp(MusicPlatform platform) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => PlatformAuthorizationScreen(
          platform: platform,
          isSource: true,
        ),
      ),
    ],
  );

  return ChangeNotifierProvider(
    create: (_) => AuthProvider(repository: MockAuthService()),
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  const testPlatform = MusicPlatform(
    id: 'spotify',
    name: 'Spotify',
    iconPath: 'assets/icons/spotify_icon.png',
    brandColor: Color(0xFF1DB954),
  );

  group('PlatformAuthorizationScreen', () {
    testWidgets('renders all UI elements', (tester) async {
      await tester.pumpWidget(_buildTestApp(testPlatform));

      expect(find.text('PullRequest'), findsOneWidget);
      expect(find.text('Connect to Spotify'), findsOneWidget);
      expect(find.text('Authorize with Spotify'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays permission description text', (tester) async {
      await tester.pumpWidget(_buildTestApp(testPlatform));

      expect(
        find.textContaining('permission to view your public playlists'),
        findsOneWidget,
      );
    });

    testWidgets('authorize button shows spinner while authorizing',
        (tester) async {
      // Use a navigable setup so context.pop() succeeds after auth completes.
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Go to Auth'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/auth',
            builder: (_, __) => PlatformAuthorizationScreen(
              platform: testPlatform,
              isSource: true,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: MockAuthService()),
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to Auth'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Authorize with Spotify'));
      await tester.pump(); // capture the in-progress state

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Drain pending timers so the test ends cleanly.
      await tester.pumpAndSettle();
    });

    testWidgets('authorization updates AuthProvider state', (tester) async {
      final authProvider = AuthProvider(repository: MockAuthService());

      // Navigate from a home route to the auth screen so context.pop() works.
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Go to Auth'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/auth',
            builder: (_, __) => PlatformAuthorizationScreen(
              platform: testPlatform,
              isSource: true,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to Auth'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Authorize with Spotify'));
      await tester.pumpAndSettle();

      expect(authProvider.stateFor('spotify'), AuthorizationState.authorized);
    });

    testWidgets('cancel button pops back to previous screen', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Go to Auth'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/auth',
            builder: (_, __) => PlatformAuthorizationScreen(
              platform: testPlatform,
              isSource: true,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: MockAuthService()),
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to auth screen
      await tester.tap(find.text('Go to Auth'));
      await tester.pumpAndSettle();
      expect(find.text('Connect to Spotify'), findsOneWidget);

      // Cancel pops back
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Connect to Spotify'), findsNothing);
    });
  });
}
