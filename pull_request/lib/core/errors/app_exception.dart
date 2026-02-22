/// Base class for all application-level exceptions.
///
/// Prefer throwing typed subclasses so callers can handle specific failure
/// modes without parsing raw exception strings.
abstract class AppException implements Exception {
  final String message;

  /// Optional machine-readable error code (e.g. HTTP status, API error code).
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Thrown when an OAuth authorization flow fails or is cancelled.
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Thrown when fetching or parsing playlist data fails.
class PlaylistException extends AppException {
  const PlaylistException(super.message, {super.code});
}

/// Thrown when a playlist transfer operation fails.
class TransferException extends AppException {
  const TransferException(super.message, {super.code});
}

/// Thrown when a network request fails (no connectivity, timeout, etc.).
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}
