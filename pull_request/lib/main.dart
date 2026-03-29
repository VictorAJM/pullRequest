import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/transfer_provider.dart';
import 'services/api_client.dart';
import 'services/backend_auth_service.dart';
import 'services/backend_playlist_service.dart';
import 'services/backend_transfer_service.dart';
import 'services/device_service.dart';
import 'services/platform_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceService = DeviceService();

  try {
    await deviceService.init();
  } catch (e) {
    runApp(_ErrorApp(message: 'Could not connect to server:\n$e'));
    return;
  }

  final apiClient = ApiClient(deviceService);
  final authRepository = BackendAuthService(apiClient);
  final playlistRepository = BackendPlaylistService(apiClient);
  final transferRepository = BackendTransferService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<PlatformService>(create: (_) => PlatformService()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(repository: playlistRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TransferProvider(repository: transferRepository),
        ),
      ],
      child: const PullRequestApp(),
    ),
  );
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
