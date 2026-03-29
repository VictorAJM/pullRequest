/// Abstract contract for platform OAuth authorization via the backend.
abstract class AuthRepository {
  /// Launches the OAuth flow for [platformId] and registers the
  /// authorization code with the backend.
  Future<void> authorize(String platformId);

  /// Returns a map of platform ID to authorization status.
  /// e.g. {'spotify': true, 'ytm': false}
  Future<Map<String, bool>> getAuthStatus();
}
