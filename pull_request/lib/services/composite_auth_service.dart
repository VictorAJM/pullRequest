import '../core/errors/app_exception.dart';
import '../models/authorization_result.dart';
import '../models/music_platform.dart';
import '../repositories/auth_repository.dart';

/// Routes auth calls to the correct per-platform [AuthRepository].
///
/// Swap any delegate for a real implementation without touching providers
/// or screens — only [main.dart] needs to change.
class CompositeAuthService implements AuthRepository {
  final Map<String, AuthRepository> _delegates;

  CompositeAuthService(this._delegates);

  AuthRepository _delegate(String platformId) {
    final delegate = _delegates[platformId];
    if (delegate == null) {
      throw AuthException('No auth handler registered for platform: $platformId');
    }
    return delegate;
  }

  @override
  Future<AuthorizationResult> authorize(MusicPlatform platform) =>
      _delegate(platform.id).authorize(platform);

  @override
  Future<bool> isAuthorized(String platformId) =>
      _delegate(platformId).isAuthorized(platformId);

  @override
  Future<void> revokeAuth(String platformId) =>
      _delegate(platformId).revokeAuth(platformId);
}
