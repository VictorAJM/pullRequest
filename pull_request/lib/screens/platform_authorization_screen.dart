import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_text_styles.dart';
import '../models/authorization_state.dart';
import '../models/music_platform.dart';
import '../providers/auth_provider.dart';

class PlatformAuthorizationScreen extends StatefulWidget {
  final MusicPlatform platform;
  final bool isSource;

  const PlatformAuthorizationScreen({
    super.key,
    required this.platform,
    required this.isSource,
  });

  @override
  State<PlatformAuthorizationScreen> createState() =>
      _PlatformAuthorizationScreenState();
}

class _PlatformAuthorizationScreenState
    extends State<PlatformAuthorizationScreen> {
  Future<void> _handleAuthorize() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.authorize(widget.platform);

    if (mounted) _safeReturn();
  }

  void _handleCancel() => _safeReturn();

  /// Pops if there is a previous route, otherwise goes to platform selection.
  /// The fallback handles Android: when the OAuth callback intent fires,
  /// GoRouter may reconstruct the stack while the browser is open, leaving
  /// this route with nothing to pop to.
  void _safeReturn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.platformSelection);
    }
  }

  bool get _isAuthorizing =>
      context.watch<AuthProvider>().stateFor(widget.platform.id) ==
      AuthorizationState.authorizing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PullRequest'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isAuthorizing ? null : _handleCancel,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    widget.platform.iconPath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Connect to ${widget.platform.name}',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'To transfer your music, PullRequest needs permission to view '
                'your public playlists. We will never post on your behalf or '
                'share your data.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isAuthorizing ? null : _handleAuthorize,
                child: _isAuthorizing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Authorize with ${widget.platform.name}'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isAuthorizing ? null : _handleCancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
