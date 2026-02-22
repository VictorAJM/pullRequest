import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/music_platform.dart';
import '../models/transfer_progress.dart';
import '../providers/playlist_provider.dart';
import '../providers/transfer_provider.dart';

class PlaylistTransferScreen extends StatefulWidget {
  final MusicPlatform sourcePlatform;
  final MusicPlatform destinationPlatform;

  const PlaylistTransferScreen({
    super.key,
    required this.sourcePlatform,
    required this.destinationPlatform,
  });

  @override
  State<PlaylistTransferScreen> createState() => _PlaylistTransferScreenState();
}

class _PlaylistTransferScreenState extends State<PlaylistTransferScreen> {
  bool _dialogShown = false;

  /// Cached to avoid calling context.read() inside dispose(), which is
  /// unsafe after the widget is deactivated.
  late final TransferProvider _transferProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _transferProvider = context.read<TransferProvider>();
      _transferProvider.addListener(_onTransferChanged);
      _startTransfer();
    });
  }

  @override
  void dispose() {
    _transferProvider.removeListener(_onTransferChanged);
    super.dispose();
  }

  void _startTransfer() {
    final playlists = context.read<PlaylistProvider>().selectedPlaylists;
    context.read<TransferProvider>().startTransfer(
          playlists,
          widget.sourcePlatform.id,
          widget.destinationPlatform.id,
        );
  }

  void _onTransferChanged() {
    final provider = context.read<TransferProvider>();
    if (provider.isCompleted && !_dialogShown && mounted) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 500), _showCompletionDialog);
    }
  }

  Future<void> _cancelTransfer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Transfer?'),
        content: const Text(
          'Are you sure you want to cancel? Progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Transfer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TransferProvider>().cancel();
      if (mounted) context.pop();
    }
  }

  void _showCompletionDialog() {
    if (!mounted) return;
    final total = context.read<PlaylistProvider>().selectedPlaylists.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Transfer Complete!')),
          ],
        ),
        content: Text(
          'Successfully transferred $total '
          'playlist${total == 1 ? '' : 's'} to '
          '${widget.destinationPlatform.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransferProvider>(
      builder: (context, provider, _) {
        return PopScope(
          canPop: provider.isCompleted || provider.isCancelled,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _cancelTransfer();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Transferring Playlists'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: provider.isCompleted || provider.isCancelled
                    ? () => context.pop()
                    : _cancelTransfer,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPlatformRow(),
                  const SizedBox(height: 48),
                  _buildProgressCircle(provider),
                  const SizedBox(height: 48),
                  _buildStatusText(provider),
                  const SizedBox(height: 16),
                  Text(
                    'Please keep the app open during transfer.',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (!provider.isCompleted && !provider.isCancelled)
                    OutlinedButton(
                      onPressed: _cancelTransfer,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlatformRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _platformColumn(widget.sourcePlatform),
        const SizedBox(width: 24),
        const Icon(
          Icons.arrow_forward,
          size: 32,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 24),
        _platformColumn(widget.destinationPlatform),
      ],
    );
  }

  Widget _platformColumn(MusicPlatform platform) {
    return Column(
      children: [
        Image.asset(platform.iconPath, width: 60, height: 60),
        const SizedBox(height: 8),
        Text(platform.name, style: AppTextStyles.label),
      ],
    );
  }

  Widget _buildProgressCircle(TransferProvider provider) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: provider.overallProgress,
              strokeWidth: 12,
              backgroundColor: AppColors.lightBlue,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryBlue,
              ),
            ),
          ),
          Text(
            '${(provider.overallProgress * 100).toInt()}%',
            style: AppTextStyles.heading1.copyWith(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(TransferProvider provider) {
    final progress = provider.currentProgress;
    if (progress == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(progress.playlistName, style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        if (progress.currentSongTitle != null &&
            progress.status == TransferStatus.inProgress)
          Text(
            'Searching: "${progress.currentSongTitle}"',
            style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 4),
        Text(
          'Adding to ${widget.destinationPlatform.name}...',
          style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Playlist ${provider.completedPlaylists + 1} '
          'of ${provider.totalPlaylists}',
          style: AppTextStyles.label.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
