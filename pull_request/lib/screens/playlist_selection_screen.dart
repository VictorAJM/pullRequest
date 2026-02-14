import 'package:flutter/material.dart';
import '../models/platform.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';
import '../widgets/playlist_card.dart';
import '../core/theme/app_colors.dart';

class PlaylistSelectionScreen extends StatefulWidget {
  final Platform platform;
  final bool isSource;

  const PlaylistSelectionScreen({
    super.key,
    required this.platform,
    required this.isSource,
  });

  @override
  State<PlaylistSelectionScreen> createState() =>
      _PlaylistSelectionScreenState();
}

class _PlaylistSelectionScreenState extends State<PlaylistSelectionScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final TextEditingController _searchController = TextEditingController();

  List<Playlist> _allPlaylists = [];
  List<Playlist> _filteredPlaylists = [];
  final Set<String> _selectedPlaylistIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
    _searchController.addListener(_filterPlaylists);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    try {
      final playlists = await _playlistService.loadPlaylists(
        widget.platform.id,
      );
      setState(() {
        _allPlaylists = playlists;
        _filteredPlaylists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPlaylists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPlaylists = _allPlaylists;
      } else {
        _filteredPlaylists = _allPlaylists
            .where(
              (playlist) =>
                  playlist.name.toLowerCase().contains(query) ||
                  (playlist.description?.toLowerCase().contains(query) ??
                      false),
            )
            .toList();
      }
    });
  }

  void _togglePlaylistSelection(String playlistId) {
    setState(() {
      if (_selectedPlaylistIds.contains(playlistId)) {
        _selectedPlaylistIds.remove(playlistId);
      } else {
        _selectedPlaylistIds.add(playlistId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      // If all filtered playlists are selected, deselect all
      // Otherwise, select all filtered playlists
      final allFilteredSelected = _filteredPlaylists.every(
        (playlist) => _selectedPlaylistIds.contains(playlist.id),
      );

      if (allFilteredSelected) {
        // Deselect all filtered playlists
        for (final playlist in _filteredPlaylists) {
          _selectedPlaylistIds.remove(playlist.id);
        }
      } else {
        // Select all filtered playlists
        _selectedPlaylistIds.addAll(
          _filteredPlaylists.map((playlist) => playlist.id),
        );
      }
    });
  }

  bool get _areAllFilteredSelected {
    if (_filteredPlaylists.isEmpty) return false;
    return _filteredPlaylists.every(
      (playlist) => _selectedPlaylistIds.contains(playlist.id),
    );
  }

  void _handleContinue() {
    if (_selectedPlaylistIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one playlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get selected playlists
    final selectedPlaylists = _allPlaylists
        .where((playlist) => _selectedPlaylistIds.contains(playlist.id))
        .toList();

    // For now, just show a success message
    // In a real app, this would navigate to the next screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected ${selectedPlaylists.length} playlist${selectedPlaylists.length == 1 ? '' : 's'} from ${widget.platform.name}',
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
    );

    // Navigate back or to the next screen
    Navigator.pop(context, selectedPlaylists);
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
        title: Text(
          widget.isSource ? 'Select Playlists' : 'Choose Destination',
          style: const TextStyle(
            color: AppColors.darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading playlists',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadPlaylists();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Platform info header
                Container(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.platform.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            Text(
                              '${_allPlaylists.length} playlists available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search playlists...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryBlue,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.lightBlue,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.lightBlue,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Toggle select all button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: _toggleSelectAll,
                        icon: Icon(
                          _areAllFilteredSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: _areAllFilteredSelected
                              ? AppColors.primaryBlue
                              : Colors.grey[600],
                        ),
                        label: Text(
                          _areAllFilteredSelected
                              ? 'Deselect All'
                              : 'Select All',
                          style: TextStyle(
                            color: _areAllFilteredSelected
                                ? AppColors.primaryBlue
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Playlist list
                Expanded(
                  child: _filteredPlaylists.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No playlists found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _filteredPlaylists.length,
                          itemBuilder: (context, index) {
                            final playlist = _filteredPlaylists[index];
                            final isSelected = _selectedPlaylistIds.contains(
                              playlist.id,
                            );
                            return PlaylistCard(
                              playlist: playlist,
                              isSelected: isSelected,
                              onTap: () =>
                                  _togglePlaylistSelection(playlist.id),
                            );
                          },
                        ),
                ),
                // Bottom action button
                Container(
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedPlaylistIds.isEmpty
                            ? null
                            : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.background,
                          disabledBackgroundColor: AppColors.lightBlue,
                          disabledForegroundColor: Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          _selectedPlaylistIds.isEmpty
                              ? 'Select Playlists'
                              : 'Continue (${_selectedPlaylistIds.length} selected)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
