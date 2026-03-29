import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/music_platform.dart';
import '../providers/auth_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/platform_service.dart';
import '../widgets/platform_card.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  State<PlatformSelectionScreen> createState() =>
      _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  MusicPlatform? _sourcePlatform;

  MusicPlatform? _getDestination(List<MusicPlatform> platforms) {
    if (_sourcePlatform == null) return null;
    return platforms.firstWhere((p) => p.id != _sourcePlatform!.id);
  }

  Future<void> _handleContinue() async {
    final platforms =
        context.read<PlatformService>().getAvailablePlatforms();
    final destination = _getDestination(platforms)!;
    final authProvider = context.read<AuthProvider>();
    final playlistProvider = context.read<PlaylistProvider>();

    playlistProvider.clearSelection();

    // Fetch auth status from backend.
    await authProvider.checkStatus();
    if (!mounted) return;
    debugPrint('Si despues de esto no se imprime nada es porque si esta autorizado');
    // Authorize source if needed.
    if (!authProvider.isAuthorized(_sourcePlatform!.id)) {
      debugPrint('Esto significa que no estas autorizado');
      final success = await context.push<bool>(
        AppRoutes.authorize,
        extra: _sourcePlatform!,
      );
      if (!mounted || success != true) return;
    }

    // Authorize destination if needed.
    if (!authProvider.isAuthorized(destination.id)) {
      final success = await context.push<bool>(
        AppRoutes.authorize,
        extra: destination,
      );
      if (!mounted || success != true) return;
    }

    // Select playlist.
    final confirmed = await context.push<bool>(
      AppRoutes.playlistSelection,
      extra: _sourcePlatform!,
    );
    if (!mounted || confirmed != true) return;

    // Start transfer.
    context.push(
      AppRoutes.transfer,
      extra: TransferArgs(
        sourcePlatform: _sourcePlatform!,
        destinationPlatform: destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platforms =
        context.read<PlatformService>().getAvailablePlatforms();
    final destination = _getDestination(platforms);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PullRequest'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Where are your playlists?',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                'Select the platform you want to transfer from.',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ...platforms.map((platform) {
                final isSelected = _sourcePlatform?.id == platform.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlatformCard(
                    platform: platform,
                    isSelected: isSelected,
                    onTap: () => setState(() => _sourcePlatform = platform),
                  ),
                );
              }),
              if (_sourcePlatform != null && destination != null) ...[
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(_sourcePlatform!.iconPath,
                          width: 32, height: 32),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.primaryBlue),
                      const SizedBox(width: 12),
                      Image.asset(destination.iconPath,
                          width: 32, height: 32),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${_sourcePlatform!.name} to ${destination.name}',
                    style: AppTextStyles.label
                        .copyWith(color: Colors.grey[600]),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed:
                    _sourcePlatform != null ? _handleContinue : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
