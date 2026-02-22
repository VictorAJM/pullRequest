import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/playlist.dart';
import '../widgets/song_card.dart';

class PlaylistDetailsScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailsScreen({super.key, required this.playlist});

  String _totalDuration() {
    final total = playlist.songs.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    return h > 0 ? '$h hr $m min' : '$m min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildSongList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightBlue, AppColors.background],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            playlist.name,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          if (playlist.description != null &&
              playlist.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              playlist.description!,
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${playlist.songs.length} songs',
                style: AppTextStyles.label.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _totalDuration(),
                style: AppTextStyles.label.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    if (playlist.songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No songs in this playlist',
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: playlist.songs.length,
      itemBuilder: (context, index) =>
          SongCard(song: playlist.songs[index], index: index),
    );
  }
}
