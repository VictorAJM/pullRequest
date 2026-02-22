import '../core/errors/app_exception.dart';
import '../models/authorization_result.dart';
import '../models/music_platform.dart';
import '../repositories/auth_repository.dart';

/// Simulates OAuth authorization with a short delay.
///
/// Replace this with SpotifyAuthService / YtMusicAuthService once OAuth
/// credentials and the redirect-callback mechanism are in place.
class MockAuthService implements AuthRepository {
  final Set<String> _authorizedPlatformIds = {};

  @override
  Future<AuthorizationResult> authorize(MusicPlatform platform) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulate a successful auth every time (no real token exchange).
    _authorizedPlatformIds.add(platform.id);
    return AuthorizationResult.success(platform);
  }

  @override
  Future<void> revokeAuth(String platformId) async {
    _authorizedPlatformIds.remove(platformId);
  }

  @override
  Future<bool> isAuthorized(String platformId) async {
    return _authorizedPlatformIds.contains(platformId);
  }
}
