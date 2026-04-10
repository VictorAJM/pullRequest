import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../providers/playlist_provider.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/loading_song_card.dart';
import '../widgets/song_card.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylistDetails(
            widget.playlist.platformId,
            widget.playlist.id,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoadingDetails(widget.playlist.id);
        final error = provider.detailErrorFor(widget.playlist.id);
        final fullPlaylist =
            provider.detailsFor(widget.playlist.id) ?? widget.playlist;

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
              _buildHeader(fullPlaylist),
              Expanded(
                child: isLoading
                    ? _buildSkeleton()
                    : error != null
                        ? ErrorView(
                            message: error,
                            onRetry: () => provider.loadPlaylistDetails(
                              widget.playlist.platformId,
                              widget.playlist.id,
                              forceRefresh: true,
                            ),
                          )
                        : _buildSongList(fullPlaylist.songs),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Playlist playlist) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: playlist.imageUrl != null
                ? Image.network(
                    playlist.imageUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, trace) => _defaultCover(),
                  )
                : _defaultCover(),
          ),
          const SizedBox(height: 16),
          Text(
            playlist.title,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${playlist.songs.isNotEmpty ? playlist.songs.length : playlist.itemCount} songs',
                style:
                    AppTextStyles.label.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.music_note, size: 60, color: Colors.white),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => const LoadingSongCard(),
    );
  }

  Widget _buildSongList(List<Song> songs) {
    if (songs.isEmpty) {
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
      itemCount: songs.length,
      itemBuilder: (context, index) =>
          SongCard(song: songs[index], index: index),
    );
  }
}
