import '../models/playlist.dart';

/// Abstract contract for fetching playlist data from a music platform.
///
/// Concrete implementations:
///   - MockPlaylistService       — reads from local JSON assets (current)
///   - SpotifyPlaylistService    — calls Spotify Web API (planned)
///   - YtMusicPlaylistService    — calls YouTube Music API (planned)
abstract class PlaylistRepository {
  /// Returns all playlists owned or followed by the authenticated user on
  /// the given [platformId].
  ///
  /// Results should be cached by the implementation where appropriate.
  /// Throws [PlaylistException] on failure.
  Future<List<Playlist>> fetchPlaylists(String platformId);

  /// Returns a single playlist including its full song list.
  ///
  /// Used when the initial list fetch omits track details for performance.
  /// Throws [PlaylistException] on failure.
  Future<Playlist> fetchPlaylistDetails(String platformId, String playlistId);
}
