import 'music_platform.dart';

class AuthorizationResult {
  final bool isAuthorized;
  final MusicPlatform platform;
  final String? errorMessage;

  const AuthorizationResult({
    required this.isAuthorized,
    required this.platform,
    this.errorMessage,
  });

  factory AuthorizationResult.success(MusicPlatform platform) {
    return AuthorizationResult(isAuthorized: true, platform: platform);
  }

  factory AuthorizationResult.failure(
    MusicPlatform platform,
    String errorMessage,
  ) {
    return AuthorizationResult(
      isAuthorized: false,
      platform: platform,
      errorMessage: errorMessage,
    );
  }
}
