import '../core/errors/app_exception.dart';
import '../models/playlist.dart';
import '../repositories/playlist_repository.dart';

/// Routes [PlaylistRepository] calls to the correct per-platform delegate.
///
/// Mirrors [CompositeAuthService]: swap any delegate for a real implementation
/// in [main.dart] without touching providers or screens.
class CompositePlaylistService implements PlaylistRepository {
  final Map<String, PlaylistRepository> _delegates;

  CompositePlaylistService(this._delegates);

  PlaylistRepository _delegate(String platformId) {
    final delegate = _delegates[platformId];
    if (delegate == null) {
      throw PlaylistException(
          'No playlist handler registered for platform: $platformId');
    }
    return delegate;
  }

  @override
  Future<List<Playlist>> fetchPlaylists(String platformId) =>
      _delegate(platformId).fetchPlaylists(platformId);

  @override
  Future<Playlist> fetchPlaylistDetails(String platformId, String playlistId) =>
      _delegate(platformId).fetchPlaylistDetails(platformId, playlistId);
}
