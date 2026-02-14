import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../widgets/song_card.dart';
import '../core/theme/app_colors.dart';

class PlaylistDetailsScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailsScreen({super.key, required this.playlist});

  String _getTotalDuration() {
    final totalSeconds = playlist.songs.fold<int>(
      0,
      (sum, song) => sum + song.durationSeconds,
    );
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Playlist Details',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Playlist header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.lightBlue, AppColors.background],
              ),
            ),
            child: Column(
              children: [
                // Playlist icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Playlist name
                Text(
                  playlist.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Playlist description
                if (playlist.description != null &&
                    playlist.description!.isNotEmpty)
                  Text(
                    playlist.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 12),
                // Playlist stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${playlist.songs.length} songs',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getTotalDuration(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Songs list
          Expanded(
            child: playlist.songs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No songs in this playlist',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: playlist.songs.length,
                    itemBuilder: (context, index) {
                      final song = playlist.songs[index];
                      return SongCard(song: song, index: index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
