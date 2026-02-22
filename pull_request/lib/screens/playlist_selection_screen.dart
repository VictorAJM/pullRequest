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
  List<Playlist> _filtered = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylists(widget.platform.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final provider = context.read<PlaylistProvider>();
    final all = provider.playlistsFor(widget.platform.id);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? all
          : all
              .where(
                (p) =>
                    p.name.toLowerCase().contains(query) ||
                    (p.description?.toLowerCase().contains(query) ?? false),
              )
              .toList();
    });
  }

  bool _areAllFilteredSelected(PlaylistProvider provider) {
    if (_filtered.isEmpty) return false;
    return _filtered.every((p) => provider.isSelected(p.id));
  }

  void _toggleSelectAll(PlaylistProvider provider) {
    if (_areAllFilteredSelected(provider)) {
      provider.deselectAll(_filtered);
    } else {
      provider.selectAll(_filtered);
    }
  }

  void _handleContinue() {
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading(widget.platform.id);
        final error = provider.errorFor(widget.platform.id);
        final all = provider.playlistsFor(widget.platform.id);
        final selectedCount = provider.selectedIds.length;

        // Sync _filtered when data first loads or changes externally.
        if (!isLoading && error == null && _filtered.isEmpty && all.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _applyFilter();
          });
        }

        final displayList = _searchController.text.isEmpty ? all : _filtered;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Playlists'),
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
                        _buildSelectAllRow(provider),
                        Expanded(child: _buildList(provider, displayList)),
                        _buildBottomBar(selectedCount),
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
      itemBuilder: (_, __) => const LoadingPlaylistCard(),
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
                style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
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
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
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

  Widget _buildSelectAllRow(PlaylistProvider provider) {
    final allSelected = _areAllFilteredSelected(provider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => _toggleSelectAll(provider),
            icon: Icon(
              allSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color:
                  allSelected ? AppColors.primaryBlue : Colors.grey[600],
            ),
            label: Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: TextStyle(
                color:
                    allSelected ? AppColors.primaryBlue : Colors.grey[600],
              ),
            ),
          ),
        ],
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
        return PlaylistCard(
          playlist: playlist,
          isSelected: provider.isSelected(playlist.id),
          onTap: () => provider.toggleSelection(playlist.id),
        );
      },
    );
  }

  Widget _buildBottomBar(int selectedCount) {
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
          onPressed: selectedCount == 0 ? null : _handleContinue,
          child: Text(
            selectedCount == 0
                ? 'Select Playlists'
                : 'Continue ($selectedCount selected)',
          ),
        ),
      ),
    );
  }
}
