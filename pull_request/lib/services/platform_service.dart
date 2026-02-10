import '../models/platform.dart';

class PlatformService {
  static const List<Platform> _platforms = [
    Platform(
      id: 'spotify',
      name: 'Spotify',
      iconPath: 'assets/icons/spotify_icon.png',
    ),
    Platform(
      id: 'youtube_music',
      name: 'YouTube Music',
      iconPath: 'assets/icons/youtube_music_icon.png',
    ),
  ];

  List<Platform> getAvailablePlatforms() {
    return List.unmodifiable(_platforms);
  }

  Platform? getPlatformById(String id) {
    try {
      return _platforms.firstWhere((platform) => platform.id == id);
    } catch (e) {
      return null;
    }
  }
}
