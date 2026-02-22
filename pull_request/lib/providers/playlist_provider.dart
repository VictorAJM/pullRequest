import 'package:flutter/foundation.dart';
import '../core/errors/app_exception.dart';
import '../models/playlist.dart';
import '../repositories/playlist_repository.dart';

/// Manages playlist loading, caching, and selection state.
///
/// Playlist data is cached by platform ID — a second call to [loadPlaylists]
/// for the same platform returns immediately from cache.
/// Call [clearCache] when a fresh fetch is needed (e.g. after OAuth re-auth).
///
/// Selection state persists across navigation. Call [clearSelection] at the
/// start of each new transfer flow to avoid stale selections.
class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _repository;

  final Map<String, List<Playlist>> _playlists = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};
  final Set<String> _selectedIds = {};

  // ── Detail state (one fetched Playlist with songs per playlist ID) ─────────
  final Map<String, Playlist?> _details = {};
  final Map<String, bool> _loadingDetails = {};
  final Map<String, String?> _detailErrors = {};

  PlaylistProvider({required PlaylistRepository repository})
      : _repository = repository;

  // ── Playlist data ─────────────────────────────────────────────────────────

  /// All playlists loaded for [platformId], or an empty list if not yet loaded.
  List<Playlist> playlistsFor(String platformId) =>
      _playlists[platformId] ?? const [];

  /// Whether playlists are currently being fetched for [platformId].
  bool isLoading(String platformId) => _loading[platformId] ?? false;

  /// Last error message for [platformId], or null if no error occurred.
  String? errorFor(String platformId) => _errors[platformId];

  /// Fetches playlists for [platformId], using cache when available.
  ///
  /// Call with [forceRefresh] = true to bypass the cache.
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
    } on PlaylistException catch (e) {
      _errors[platformId] = e.message;
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

  // ── Playlist detail ────────────────────────────────────────────────────────

  /// Fetched [Playlist] with full song list for [playlistId], or null if not
  /// yet loaded.
  Playlist? detailsFor(String playlistId) => _details[playlistId];

  /// Whether a detail fetch is in progress for [playlistId].
  bool isLoadingDetails(String playlistId) =>
      _loadingDetails[playlistId] ?? false;

  /// Last error from a detail fetch for [playlistId], or null if no error.
  String? detailErrorFor(String playlistId) => _detailErrors[playlistId];

  /// Fetches the full playlist (with songs) for [playlistId], caching the
  /// result. Call with [forceRefresh] = true to bypass the cache.
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
      _details[playlistId] = await _repository.fetchPlaylistDetails(
        platformId,
        playlistId,
      );
    } on PlaylistException catch (e) {
      _detailErrors[playlistId] = e.message;
    } catch (e) {
      _detailErrors[playlistId] = e.toString();
    } finally {
      _loadingDetails[playlistId] = false;
      notifyListeners();
    }
  }

  // ── Selection state ───────────────────────────────────────────────────────

  /// Immutable view of currently selected playlist IDs.
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  /// All selected [Playlist] objects across all loaded platforms.
  List<Playlist> get selectedPlaylists => _playlists.values
      .expand((list) => list)
      .where((p) => _selectedIds.contains(p.id))
      .toList();

  bool isSelected(String playlistId) => _selectedIds.contains(playlistId);

  void toggleSelection(String playlistId) {
    if (_selectedIds.contains(playlistId)) {
      _selectedIds.remove(playlistId);
    } else {
      _selectedIds.add(playlistId);
    }
    notifyListeners();
  }

  void selectAll(List<Playlist> playlists) {
    _selectedIds.addAll(playlists.map((p) => p.id));
    notifyListeners();
  }

  void deselectAll(List<Playlist> playlists) {
    for (final p in playlists) {
      _selectedIds.remove(p.id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }
}
