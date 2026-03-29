import '../models/playlist.dart';
import '../models/song.dart';

/// Abstract contract for fetching playlist data via the backend.
abstract class PlaylistRepository {
  /// Returns all playlists for the authenticated user on [platformId].
  Future<List<Playlist>> fetchPlaylists(String platformId);

  /// Returns the songs in a specific playlist.
  Future<List<Song>> fetchPlaylistSongs(String platformId, String playlistId);
}
