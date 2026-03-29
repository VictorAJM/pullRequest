import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../repositories/playlist_repository.dart';

/// Manages playlist loading, caching, detail fetching, and selection.
///
/// Uses single-select: one playlist at a time for transfer.
class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _repository;

  final Map<String, List<Playlist>> _playlists = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};
  String? _selectedPlaylistId;

  final Map<String, Playlist?> _details = {};
  final Map<String, bool> _loadingDetails = {};
  final Map<String, String?> _detailErrors = {};

  PlaylistProvider({required PlaylistRepository repository})
      : _repository = repository;

  // ── Playlist list ────────────────────────────────────────────────────────

  List<Playlist> playlistsFor(String platformId) =>
      _playlists[platformId] ?? const [];

  bool isLoading(String platformId) => _loading[platformId] ?? false;

  String? errorFor(String platformId) => _errors[platformId];

  Future<void> loadPlaylists(
    String platformId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _playlists.containsKey(platformId)) return;

    _loading[platformId] = true;
    _errors[platformId] = null;
    notifyListeners();

    try {
      _playlists[platformId] = await _repository.fetchPlaylists(platformId);
    } catch (e) {
      _errors[platformId] = e.toString();
    } finally {
      _loading[platformId] = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _playlists.clear();
    _details.clear();
    _detailErrors.clear();
    notifyListeners();
  }

  // ── Single selection ─────────────────────────────────────────────────────

  String? get selectedPlaylistId => _selectedPlaylistId;

  Playlist? get selectedPlaylist {
    if (_selectedPlaylistId == null) return null;
    for (final list in _playlists.values) {
      for (final p in list) {
        if (p.id == _selectedPlaylistId) return p;
      }
    }
    return null;
  }

  void selectPlaylist(String? playlistId) {
    _selectedPlaylistId = playlistId;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPlaylistId = null;
    notifyListeners();
  }

  // ── Playlist detail ──────────────────────────────────────────────────────

  Playlist? detailsFor(String playlistId) => _details[playlistId];

  bool isLoadingDetails(String playlistId) =>
      _loadingDetails[playlistId] ?? false;

  String? detailErrorFor(String playlistId) => _detailErrors[playlistId];

  Future<void> loadPlaylistDetails(
    String platformId,
    String playlistId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _details.containsKey(playlistId)) return;

    _loadingDetails[playlistId] = true;
    _detailErrors[playlistId] = null;
    notifyListeners();

    try {
      final songs =
          await _repository.fetchPlaylistSongs(platformId, playlistId);

      // Merge with list-level metadata if available.
      Playlist? listPlaylist;
      for (final list in _playlists.values) {
        for (final p in list) {
          if (p.id == playlistId) {
            listPlaylist = p;
            break;
          }
        }
        if (listPlaylist != null) break;
      }

      _details[playlistId] = Playlist(
        id: playlistId,
        title: listPlaylist?.title ?? '',
        itemCount: songs.length,
        imageUrl: listPlaylist?.imageUrl,
        platformId: platformId,
        songs: songs,
      );
    } catch (e) {
      _detailErrors[playlistId] = e.toString();
    } finally {
      _loadingDetails[playlistId] = false;
      notifyListeners();
    }
  }
}
