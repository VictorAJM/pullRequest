import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pull_request/app.dart';
import 'package:pull_request/providers/auth_provider.dart';
import 'package:pull_request/providers/playlist_provider.dart';
import 'package:pull_request/providers/transfer_provider.dart';
import 'package:pull_request/services/mock_auth_service.dart';
import 'package:pull_request/services/mock_playlist_service.dart';
import 'package:pull_request/services/mock_transfer_service.dart';
import 'package:pull_request/services/platform_service.dart';

void main() {
  testWidgets('PullRequest home screen renders correctly', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PlatformService>(create: (_) => PlatformService()),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(repository: MockAuthService()),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                PlaylistProvider(repository: MockPlaylistService()),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                TransferProvider(repository: MockTransferService()),
          ),
        ],
        child: const PullRequestApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PullRequest'), findsOneWidget);
    expect(find.text('Move your music between'), findsOneWidget);
    expect(find.text('platforms in seconds.'), findsOneWidget);
    expect(find.text('Start Transfer'), findsOneWidget);
  });
}
