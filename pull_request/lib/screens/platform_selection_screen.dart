import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../models/music_platform.dart';
import '../providers/auth_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/platform_service.dart';
import '../widgets/platform_selector.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  State<PlatformSelectionScreen> createState() =>
      _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  MusicPlatform? _sourcePlatform;
  MusicPlatform? _destinationPlatform;

  bool get _canProceed =>
      _sourcePlatform != null && _destinationPlatform != null;

  List<String> get _disabledSourceIds =>
      _destinationPlatform != null ? [_destinationPlatform!.id] : [];

  List<String> get _disabledDestinationIds =>
      _sourcePlatform != null ? [_sourcePlatform!.id] : [];

  void _handleSourceSelection(MusicPlatform platform) {
    setState(() {
      _sourcePlatform = platform;
      if (_destinationPlatform?.id == platform.id) {
        _destinationPlatform = null;
      }
    });
  }

  void _handleDestinationSelection(MusicPlatform platform) {
    setState(() {
      _destinationPlatform = platform;
      if (_sourcePlatform?.id == platform.id) {
        _sourcePlatform = null;
      }
    });
  }

  Future<void> _handleSelectPlaylists() async {
    final authProvider = context.read<AuthProvider>();
    final playlistProvider = context.read<PlaylistProvider>();

    // Clear any selection from a previous transfer flow.
    playlistProvider.clearSelection();

    // ── Authorize source ───────────────────────────────────────────────────
    // The auth screen pops with `true` on success, `false` on cancel/failure.
    final sourceAuthorized = await context.push<bool>(
      AppRoutes.authorize,
      extra: AuthorizationArgs(
        platform: _sourcePlatform!,
        isSource: true,
      ),
    );

    if (!mounted) return;
    if (sourceAuthorized != true) {
      _showAuthorizationError(
        _sourcePlatform!.name,
        authProvider.errorFor(_sourcePlatform!.id) ??
            'Authorization was cancelled.',
      );
      return;
    }

    // ── Authorize destination ──────────────────────────────────────────────
    final destAuthorized = await context.push<bool>(
      AppRoutes.authorize,
      extra: AuthorizationArgs(
        platform: _destinationPlatform!,
        isSource: false,
      ),
    );

    if (!mounted) return;
    if (destAuthorized != true) {
      _showAuthorizationError(
        _destinationPlatform!.name,
        authProvider.errorFor(_destinationPlatform!.id) ??
            'Authorization was cancelled.',
      );
      return;
    }

    // ── Select playlists ───────────────────────────────────────────────────
    final confirmed = await context.push<bool>(
      AppRoutes.playlistSelection,
      extra: _sourcePlatform!,
    );

    if (!mounted) return;
    if (confirmed != true) return;

    // ── Start transfer ─────────────────────────────────────────────────────
    context.push(
      AppRoutes.transfer,
      extra: TransferArgs(
        sourcePlatform: _sourcePlatform!,
        destinationPlatform: _destinationPlatform!,
      ),
    );
  }

  void _showAuthorizationError(String platformName, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authorization Failed'),
        content: Text('Could not authorize $platformName: $message'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platforms =
        context.read<PlatformService>().getAvailablePlatforms();

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
            children: [
              PlatformSelector(
                title: 'FROM (Source)',
                selectedPlatform: _sourcePlatform,
                availablePlatforms: platforms,
                disabledPlatformIds: _disabledSourceIds,
                onPlatformSelected: _handleSourceSelection,
                onClear: () => setState(() => _sourcePlatform = null),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.arrow_downward,
                size: 32,
                color: AppColors.darkBlue,
              ),
              const SizedBox(height: 24),
              PlatformSelector(
                title: 'TO (Destination)',
                selectedPlatform: _destinationPlatform,
                availablePlatforms: platforms,
                disabledPlatformIds: _disabledDestinationIds,
                onPlatformSelected: _handleDestinationSelection,
                onClear: () => setState(() => _destinationPlatform = null),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _canProceed ? _handleSelectPlaylists : null,
                child: const Text('Select Playlists'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
