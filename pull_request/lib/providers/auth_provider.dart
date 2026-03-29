import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

/// Manages OAuth authorization state for all music platforms.
///
/// Screens check status via [isAuthorized] and trigger flows via
/// [authorize]. Auth status is fetched from the backend.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  Map<String, bool> _status = {};
  bool _isLoading = false;
  bool _isAuthorizing = false;
  String? _error;

  AuthProvider({required AuthRepository repository})
      : _repository = repository;

  bool isAuthorized(String platformId) => _status[platformId] ?? false;
  bool get isLoading => _isLoading;
  bool get isAuthorizing => _isAuthorizing;
  String? get error => _error;

  /// Fetches the current authorization status from the backend.
  Future<void> checkStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _status = await _repository.getAuthStatus();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Launches the OAuth flow for [platformId]. Returns true on success.
  Future<bool> authorize(String platformId) async {
    _isAuthorizing = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.authorize(platformId);
      _status[platformId] = true;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isAuthorizing = false;
      notifyListeners();
    }
  }
}
