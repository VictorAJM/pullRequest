import 'package:flutter/material.dart';
import 'dart:async';
import '../models/platform.dart';
import '../models/playlist.dart';
import '../models/transfer_progress.dart';
import '../services/transfer_service.dart';
import '../core/theme/app_colors.dart';

class PlaylistTransferScreen extends StatefulWidget {
  final List<Playlist> selectedPlaylists;
  final Platform sourcePlatform;
  final Platform destinationPlatform;

  const PlaylistTransferScreen({
    super.key,
    required this.selectedPlaylists,
    required this.sourcePlatform,
    required this.destinationPlatform,
  });

  @override
  State<PlaylistTransferScreen> createState() => _PlaylistTransferScreenState();
}

class _PlaylistTransferScreenState extends State<PlaylistTransferScreen> {
  final TransferService _transferService = TransferService();
  StreamSubscription<TransferProgress>? _transferSubscription;

  TransferProgress? _currentProgress;
  int _completedPlaylists = 0;
  bool _isCancelled = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTransfer();
  }

  @override
  void dispose() {
    _transferSubscription?.cancel();
    super.dispose();
  }

  void _startTransfer() {
    final stream = _transferService.transferPlaylists(
      widget.selectedPlaylists,
      widget.sourcePlatform.id,
      widget.destinationPlatform.id,
    );

    _transferSubscription = stream.listen(
      (progress) {
        if (_isCancelled) return;

        setState(() {
          _currentProgress = progress;

          if (progress.status == TransferStatus.completed) {
            _completedPlaylists++;

            // Check if all playlists are done
            if (_completedPlaylists == widget.selectedPlaylists.length) {
              _isCompleted = true;
              _showCompletionDialog();
            }
          }
        });
      },
      onError: (error) {
        // Handle errors silently or show a dialog if needed
      },
      onDone: () {
        if (!_isCompleted && !_isCancelled) {
          setState(() {
            _isCompleted = true;
          });
          _showCompletionDialog();
        }
      },
    );
  }

  void _cancelTransfer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Transfer?',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel the transfer? Progress will be lost.',
          style: TextStyle(color: AppColors.darkBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continue Transfer',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isCancelled = true;
              });
              _transferSubscription?.cancel();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
              const Expanded(
                child: Text(
                  'Transfer Complete!',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Successfully transferred ${widget.selectedPlaylists.length} playlist${widget.selectedPlaylists.length == 1 ? '' : 's'} to ${widget.destinationPlatform.name}.',
            style: const TextStyle(color: AppColors.darkBlue),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close transfer screen
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  double get _overallProgress {
    if (widget.selectedPlaylists.isEmpty) return 0.0;

    // Calculate progress based on completed playlists
    double totalProgress = _completedPlaylists.toDouble();

    // Add current playlist progress only if it's in progress (not completed)
    if (_currentProgress != null &&
        _currentProgress!.status == TransferStatus.inProgress) {
      totalProgress += _currentProgress!.progress;
    }

    // Divide by total playlists to get percentage
    return totalProgress / widget.selectedPlaylists.length;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isCompleted || _isCancelled,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_isCompleted && !_isCancelled) {
          _cancelTransfer();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.lightBlue,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.darkBlue),
            onPressed: _isCompleted || _isCancelled
                ? () => Navigator.pop(context)
                : _cancelTransfer,
          ),
          title: const Text(
            'Transferring Playlists',
            style: TextStyle(
              color: AppColors.darkBlue,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Platform transfer indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Source platform
                  Column(
                    children: [
                      Image.asset(
                        widget.sourcePlatform.iconPath,
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.sourcePlatform.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Arrow
                  const Icon(
                    Icons.arrow_forward,
                    size: 32,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 24),
                  // Destination platform
                  Column(
                    children: [
                      Image.asset(
                        widget.destinationPlatform.iconPath,
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.destinationPlatform.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Progress circle
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: _overallProgress,
                        strokeWidth: 12,
                        backgroundColor: AppColors.lightBlue,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    Text(
                      '${(_overallProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Current status
              if (_currentProgress != null) ...[
                Text(
                  _currentProgress!.playlistName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (_currentProgress!.currentSongTitle != null)
                  Text(
                    'Searching for: \'${_currentProgress!.currentSongTitle}\' - ${_currentProgress!.playlistName}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 4),
                Text(
                  'Adding to ${widget.destinationPlatform.name}...',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Playlist ${_completedPlaylists + 1} of ${widget.selectedPlaylists.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Info text
              Text(
                'Please keep the app open during transfer.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Cancel button
              if (!_isCompleted && !_isCancelled)
                OutlinedButton(
                  onPressed: _cancelTransfer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
