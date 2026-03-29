import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/music_platform.dart';
import '../models/playlist.dart';
import '../providers/playlist_provider.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/loading_playlist_card.dart';
import '../widgets/playlist_card.dart';

class PlaylistSelectionScreen extends StatefulWidget {
  final MusicPlatform platform;

  const PlaylistSelectionScreen({super.key, required this.platform});

  @override
  State<PlaylistSelectionScreen> createState() =>
      _PlaylistSelectionScreenState();
}

class _PlaylistSelectionScreenState extends State<PlaylistSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylists(widget.platform.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Playlist> _filterPlaylists(List<Playlist> all) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return all;
    return all.where((p) => p.title.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading(widget.platform.id);
        final error = provider.errorFor(widget.platform.id);
        final all = provider.playlistsFor(widget.platform.id);
        final displayList = _filterPlaylists(all);
        final selected = provider.selectedPlaylist;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Playlist'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(false),
            ),
          ),
          body: isLoading
              ? _buildSkeleton()
              : error != null
                  ? ErrorView(
                      message: error,
                      onRetry: () => provider.loadPlaylists(
                        widget.platform.id,
                        forceRefresh: true,
                      ),
                    )
                  : Column(
                      children: [
                        _buildHeader(all.length),
                        _buildSearchBar(),
                        Expanded(
                            child: _buildList(provider, displayList)),
                        _buildBottomBar(selected),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => const LoadingPlaylistCard(),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.lightBlue,
      child: Row(
        children: [
          Image.asset(
            widget.platform.iconPath,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.platform.name, style: AppTextStyles.bodyMedium),
              Text(
                '$count playlists available',
                style:
                    AppTextStyles.caption.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search playlists...',
          prefixIcon:
              const Icon(Icons.search, color: AppColors.primaryBlue),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _searchController.clear,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildList(PlaylistProvider provider, List<Playlist> playlists) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No playlists found',
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        final isSelected = provider.selectedPlaylistId == playlist.id;
        return PlaylistCard(
          playlist: playlist,
          isSelected: isSelected,
          onTap: () => provider.selectPlaylist(
            isSelected ? null : playlist.id,
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(Playlist? selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: selected == null ? null : () => context.pop(true),
          child: Text(
            selected == null
                ? 'Select a Playlist'
                : 'Transfer "${selected.title}"',
          ),
        ),
      ),
    );
  }
}
