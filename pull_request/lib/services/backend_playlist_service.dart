import 'dart:convert';
import '../core/errors/app_exception.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../repositories/playlist_repository.dart';
import 'api_client.dart';

/// Implements [PlaylistRepository] by calling the backend API.
class BackendPlaylistService implements PlaylistRepository {
  final ApiClient _api;

  BackendPlaylistService(this._api);

  @override
  Future<List<Playlist>> fetchPlaylists(String platformId) async {
    final response = await _api.get('/playlists/list?platform=$platformId');
    if (response.statusCode != 200) {
      throw PlaylistException(
        'Failed to load playlists (${response.statusCode})',
      );
    }
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Song>> fetchPlaylistSongs(
    String platformId,
    String playlistId,
  ) async {
    final response = await _api.get(
      '/playlists/contents?playlist_id=$playlistId&platform=$platformId',
    );
    if (response.statusCode != 200) {
      throw PlaylistException(
        'Failed to load songs (${response.statusCode})',
      );
    }
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => Song.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
