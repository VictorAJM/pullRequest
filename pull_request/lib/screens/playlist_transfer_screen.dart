import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/music_platform.dart';
import '../models/song.dart';
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
  State<PlaylistTransferScreen> createState() =>
      _PlaylistTransferScreenState();
}

class _PlaylistTransferScreenState extends State<PlaylistTransferScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startTransfer();
    });
  }

  void _startTransfer() {
    final playlist = context.read<PlaylistProvider>().selectedPlaylist;
    if (playlist == null) return;

    context.read<TransferProvider>().startTransfer(
          playlist.id,
          widget.sourcePlatform.id,
        );
  }

  void _goHome() {
    context.read<TransferProvider>().reset();
    context.go(AppRoutes.home);
  }

  void _showFailedSongs(List<Song> songs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Songs not found (${songs.length})',
                style: AppTextStyles.heading3,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: song.imageUrl != null
                          ? Image.network(
                              song.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, trace) =>
                                  const Icon(Icons.music_note),
                            )
                          : const Icon(Icons.music_note),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransferProvider>(
      builder: (context, provider, _) {
        return PopScope(
          canPop: provider.isCompleted || provider.hasError,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Transferring'),
              automaticallyImplyLeading: false,
              actions: [
                if (provider.isCompleted || provider.hasError)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _goHome,
                  ),
              ],
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
                  if (provider.isCompleted)
                    _buildCompletionSection(provider)
                  else if (provider.hasError)
                    _buildErrorSection(provider)
                  else
                    _buildProgressSection(provider),
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
        const Icon(Icons.arrow_forward,
            size: 32, color: AppColors.primaryBlue),
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
    final isComplete = provider.isCompleted && !provider.hasError;
    final hasError = provider.hasError;

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
              valueColor: AlwaysStoppedAnimation<Color>(
                hasError
                    ? Colors.red
                    : isComplete
                        ? Colors.green
                        : AppColors.primaryBlue,
              ),
            ),
          ),
          if (isComplete)
            const Icon(Icons.check_circle, size: 64, color: Colors.green)
          else if (hasError)
            const Icon(Icons.error, size: 64, color: Colors.red)
          else
            Text(
              '${(provider.overallProgress * 100).toInt()}%',
              style: AppTextStyles.heading1.copyWith(fontSize: 48),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(TransferProvider provider) {
    final progress = provider.progress;

    return Column(
      children: [
        if (progress?.currentSong != null)
          Text(
            'Searching: "${progress!.currentSong}"',
            style:
                AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 8),
        if (progress != null)
          Text(
            '${progress.currentItem} of ${progress.totalItems} songs',
            style: AppTextStyles.label.copyWith(color: Colors.grey[600]),
          ),
        const SizedBox(height: 16),
        Text(
          'Please keep the app open during transfer.',
          style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompletionSection(TransferProvider provider) {
    final progress = provider.progress;
    final failed = provider.failedSongs;
    final total = progress?.totalItems ?? 0;
    final transferred = total - failed.length;

    return Column(
      children: [
        Text('Transfer Complete!', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text(
          failed.isEmpty
              ? 'All $total songs transferred successfully.'
              : '$transferred of $total songs transferred.',
          style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        if (failed.isNotEmpty) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showFailedSongs(failed),
            icon: const Icon(Icons.warning_amber, color: Colors.orange),
            label: Text(
              '${failed.length} songs could not be found',
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _goHome,
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildErrorSection(TransferProvider provider) {
    return Column(
      children: [
        Text('Transfer Failed', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text(
          provider.error ?? 'An unexpected error occurred.',
          style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _goHome,
          child: const Text('Go Home'),
        ),
      ],
    );
  }
}
