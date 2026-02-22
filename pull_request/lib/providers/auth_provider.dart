import 'package:flutter/foundation.dart';
import '../core/errors/app_exception.dart';
import '../models/authorization_result.dart';
import '../models/authorization_state.dart';
import '../models/music_platform.dart';
import '../repositories/auth_repository.dart';

/// Manages OAuth authorization state for all connected music platforms.
///
/// Screens read authorization state via [stateFor] / [isAuthorized] and
/// trigger flows via [authorize] / [revokeAuth].
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  final Map<String, AuthorizationState> _states = {};
  final Map<String, String> _errors = {};

  AuthProvider({required AuthRepository repository})
      : _repository = repository;

  /// Returns the current [AuthorizationState] for [platformId].
  AuthorizationState stateFor(String platformId) =>
      _states[platformId] ?? AuthorizationState.pending;

  /// Returns true when [platformId] is fully authorized.
  bool isAuthorized(String platformId) =>
      _states[platformId] == AuthorizationState.authorized;

  /// Returns the last error message for [platformId], or null if none.
  String? errorFor(String platformId) => _errors[platformId];

  /// Launches the authorization flow for [platform] and updates state.
  ///
  /// Returns the [AuthorizationResult] so callers can inspect details if
  /// needed, but state is also observable via [stateFor].
  Future<AuthorizationResult> authorize(MusicPlatform platform) async {
    _states[platform.id] = AuthorizationState.authorizing;
    _errors.remove(platform.id);
    notifyListeners();

    try {
      final result = await _repository.authorize(platform);

      _states[platform.id] = result.isAuthorized
          ? AuthorizationState.authorized
          : AuthorizationState.failed;

      if (!result.isAuthorized && result.errorMessage != null) {
        _errors[platform.id] = result.errorMessage!;
      }

      notifyListeners();
      return result;
    } on AuthException catch (e) {
      _states[platform.id] = AuthorizationState.failed;
      _errors[platform.id] = e.message;
      notifyListeners();
      return AuthorizationResult.failure(platform, e.message);
    }
  }

  /// Revokes authorization for [platformId] and resets its state.
  Future<void> revokeAuth(String platformId) async {
    await _repository.revokeAuth(platformId);
    _states.remove(platformId);
    _errors.remove(platformId);
    notifyListeners();
  }
}
