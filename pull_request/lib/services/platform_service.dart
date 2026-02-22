import 'package:flutter/material.dart';
import '../models/music_platform.dart';

class PlatformService {
  static const List<MusicPlatform> _platforms = [
    MusicPlatform(
      id: 'spotify',
      name: 'Spotify',
      iconPath: 'assets/icons/spotify_icon.png',
      brandColor: Color(0xFF1DB954),
      scopes: ['playlist-read-private', 'playlist-read-collaborative'],
    ),
    MusicPlatform(
      id: 'youtube_music',
      name: 'YouTube Music',
      iconPath: 'assets/icons/youtube_music_icon.png',
      brandColor: Color(0xFFFF0000),
      scopes: ['https://www.googleapis.com/auth/youtube.readonly'],
    ),
  ];

  List<MusicPlatform> getAvailablePlatforms() => List.unmodifiable(_platforms);

  MusicPlatform? getPlatformById(String id) {
    try {
      return _platforms.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
