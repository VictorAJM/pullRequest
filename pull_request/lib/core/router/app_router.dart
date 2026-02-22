import 'package:go_router/go_router.dart';
import '../../models/music_platform.dart';
import '../../models/playlist.dart';
import '../../screens/home_screen.dart';
import '../../screens/platform_authorization_screen.dart';
import '../../screens/platform_selection_screen.dart';
import '../../screens/playlist_details_screen.dart';
import '../../screens/playlist_selection_screen.dart';
import '../../screens/playlist_transfer_screen.dart';
import '../../screens/transfer_history_screen.dart';

// ── Route path constants ────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const platformSelection = '/select-platforms';
  static const authorize = '/authorize';
  static const playlistSelection = '/select-playlists';
  static const transfer = '/transfer';
  static const history = '/history';
  static const playlistDetails = '/playlist-details';
}

// ── Navigation argument types ───────────────────────────────────────────────

/// Passed as [GoRouterState.extra] when pushing [AppRoutes.authorize].
class AuthorizationArgs {
  final MusicPlatform platform;
  final bool isSource;

  const AuthorizationArgs({required this.platform, required this.isSource});
}

/// Passed as [GoRouterState.extra] when pushing [AppRoutes.transfer].
class TransferArgs {
  final MusicPlatform sourcePlatform;
  final MusicPlatform destinationPlatform;

  const TransferArgs({
    required this.sourcePlatform,
    required this.destinationPlatform,
  });
}

// ── Router configuration ────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.platformSelection,
      builder: (context, state) => const PlatformSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.authorize,
      builder: (context, state) {
        final args = state.extra as AuthorizationArgs;
        return PlatformAuthorizationScreen(
          platform: args.platform,
          isSource: args.isSource,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.playlistSelection,
      builder: (context, state) {
        final platform = state.extra as MusicPlatform;
        return PlaylistSelectionScreen(platform: platform);
      },
    ),
    GoRoute(
      path: AppRoutes.transfer,
      builder: (context, state) {
        final args = state.extra as TransferArgs;
        return PlaylistTransferScreen(
          sourcePlatform: args.sourcePlatform,
          destinationPlatform: args.destinationPlatform,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const TransferHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.playlistDetails,
      builder: (context, state) {
        final playlist = state.extra as Playlist;
        return PlaylistDetailsScreen(playlist: playlist);
      },
    ),
  ],
);
