import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/playlist.dart';

class PlaylistService {
  final Map<String, List<Playlist>> _cachedPlaylists = {};

  Future<List<Playlist>> loadPlaylists(String platformId) async {
    // Return cached playlists if available
    if (_cachedPlaylists.containsKey(platformId)) {
      return _cachedPlaylists[platformId]!;
    }

    // Determine the JSON file path based on platform ID
    String jsonPath;
    switch (platformId) {
      case 'spotify':
        jsonPath = 'assets/data/spotify_playlists.json';
        break;
      case 'youtube_music':
        jsonPath = 'assets/data/youtube_music_playlists.json';
        break;
      default:
        throw ArgumentError('Unknown platform ID: $platformId');
    }

    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(jsonPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // Parse the JSON into Playlist objects
      final List<Playlist> playlists = jsonList
          .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the playlists
      _cachedPlaylists[platformId] = playlists;

      return playlists;
    } catch (e) {
      throw Exception('Failed to load playlists for $platformId: $e');
    }
  }

  List<Playlist>? getPlaylistsForPlatform(String platformId) {
    return _cachedPlaylists[platformId];
  }

  void clearCache() {
    _cachedPlaylists.clear();
  }
}
