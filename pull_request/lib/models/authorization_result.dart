import 'platform.dart';

class AuthorizationResult {
  final bool isAuthorized;
  final Platform platform;
  final String? errorMessage;

  const AuthorizationResult({
    required this.isAuthorized,
    required this.platform,
    this.errorMessage,
  });

  factory AuthorizationResult.success(Platform platform) {
    return AuthorizationResult(isAuthorized: true, platform: platform);
  }

  factory AuthorizationResult.failure(Platform platform, String errorMessage) {
    return AuthorizationResult(
      isAuthorized: false,
      platform: platform,
      errorMessage: errorMessage,
    );
  }
}
