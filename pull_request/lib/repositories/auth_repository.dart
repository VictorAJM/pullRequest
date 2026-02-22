import '../models/music_platform.dart';
import '../models/authorization_result.dart';

/// Abstract contract for platform OAuth authorization.
///
/// Concrete implementations:
///   - MockAuthService     — simulates auth with a delay (current)
///   - SpotifyAuthService  — real Spotify OAuth (planned)
///   - YtMusicAuthService  — real YouTube Music OAuth (planned)
abstract class AuthRepository {
  /// Launches the authorization flow for [platform] and returns the result.
  ///
  /// Throws [AuthException] on unrecoverable errors.
  Future<AuthorizationResult> authorize(MusicPlatform platform);

  /// Revokes stored credentials for [platformId].
  Future<void> revokeAuth(String platformId);

  /// Returns true if valid credentials are stored for [platformId].
  Future<bool> isAuthorized(String platformId);
}
