import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/errors/app_exception.dart';
import '../models/playlist.dart';
import '../repositories/playlist_repository.dart';

/// Serves playlist data from local JSON asset files.
///
/// Replace per platform with SpotifyPlaylistService / YtMusicPlaylistService
/// once the respective OAuth flows are in place. Only main.dart needs to
/// change — PlaylistProvider and all screens remain untouched.
class MockPlaylistService implements PlaylistRepository {
  /// Asset paths keyed by platform ID.
  static const Map<String, String> _assetPaths = {
    'spotify': 'assets/data/spotify_playlists.json',
    'youtube_music': 'assets/data/youtube_music_playlists.json',
  };

  final Map<String, List<Playlist>> _cache = {};

  @override
  Future<List<Playlist>> fetchPlaylists(String platformId) async {
    if (_cache.containsKey(platformId)) {
      return _cache[platformId]!;
    }

    final assetPath = _assetPaths[platformId];
    if (assetPath == null) {
      throw PlaylistException(
        'No data source configured for platform "$platformId".',
        code: 'UNKNOWN_PLATFORM',
      );
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final playlists = jsonList
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();

      _cache[platformId] = playlists;
      return playlists;
    } catch (e) {
      if (e is PlaylistException) rethrow;
      throw PlaylistException(
        'Failed to load playlists for "$platformId": $e',
        code: 'LOAD_ERROR',
      );
    }
  }

  @override
  Future<Playlist> fetchPlaylistDetails(
    String platformId,
    String playlistId,
  ) async {
    final playlists = await fetchPlaylists(platformId);
    try {
      return playlists.firstWhere((p) => p.id == playlistId);
    } catch (_) {
      throw PlaylistException(
        'Playlist "$playlistId" not found on "$platformId".',
        code: 'NOT_FOUND',
      );
    }
  }

  void clearCache() => _cache.clear();
}
