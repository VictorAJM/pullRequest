import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/transfer_provider.dart';
import 'services/mock_auth_service.dart';
import 'services/mock_playlist_service.dart';
import 'services/mock_transfer_service.dart';
import 'services/platform_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate service implementations.
  // To switch from mock to real APIs: replace these with the real
  // implementations — no provider or screen code changes required.
  final authRepository = MockAuthService();
  final playlistRepository = MockPlaylistService();
  final transferRepository = MockTransferService();

  runApp(
    MultiProvider(
      providers: [
        // Static config — no state changes, provided for testability.
        Provider<PlatformService>(create: (_) => PlatformService()),

        // Auth state per connected platform.
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),

        // Playlist data, cache, and selection state.
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(repository: playlistRepository),
        ),

        // Active transfer stream and progress.
        ChangeNotifierProvider(
          create: (_) => TransferProvider(repository: transferRepository),
        ),
      ],
      child: const PullRequestApp(),
    ),
  );
}
