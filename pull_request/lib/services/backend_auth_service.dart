import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';
import 'api_client.dart';

/// Implements [AuthRepository] by launching an OAuth browser flow,
/// capturing the authorization code, and sending it to the backend
/// for token exchange.
class BackendAuthService implements AuthRepository {
  final ApiClient _api;
  bool _googleInitialized = false;

  BackendAuthService(this._api);

  /// Initializes GoogleSignIn once with the server client ID.
  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleClientId,
    );
    _googleInitialized = true;
  }

  @override
  Future<void> authorize(String platformId) async {
    final String code;

    if (platformId == 'ytm') {
      code = await _authorizeGoogle();
    } else {
      code = await _authorizeSpotify();
    }

    // Send code to backend for token exchange.
    final response = await _api.post(
      '/oauth/register_code',
      body: {'platform': platformId, 'code': code},
    );

    if (response.statusCode != 200) {
      throw AuthException(
        'Failed to register authorization (${response.statusCode})',
      );
    }
  }

  /// Uses Google Sign-In native flow to get a server auth code.
  Future<String> _authorizeGoogle() async {
    await _ensureGoogleInitialized();

    final GoogleSignInAccount user;
    try {
      user = await GoogleSignIn.instance.authenticate();
    } on Exception catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }

    final scopes = [AppConfig.googleScopes];
    final serverAuth = await user.authorizationClient.authorizeServer(scopes);
    if (serverAuth == null) {
      throw AuthException('No server auth code received from Google');
    }

    return serverAuth.serverAuthCode;
  }

  /// Uses FlutterWebAuth2 browser flow for Spotify.
  Future<String> _authorizeSpotify() async {
    final authUrl = _buildAuthUrl();

    final resultUrl = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'pullrequest',
    );

    final code = Uri.parse(resultUrl).queryParameters['code'];
    if (code == null) {
      throw AuthException('No authorization code received');
    }

    return code;
  }

  @override
  Future<Map<String, bool>> getAuthStatus() async {
    final response = await _api.get('/oauth/status');
    if (response.statusCode != 200) {
      throw AuthException('Failed to check auth status');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return {
      'spotify': data['spotify'] as bool? ?? false,
      'ytm': data['ytm'] as bool? ?? false,
    };
  }

  String _buildAuthUrl() {
    return 'https://accounts.spotify.com/authorize?'
        'client_id=${AppConfig.spotifyClientId}'
        '&response_type=code'
        '&redirect_uri=${Uri.encodeComponent(AppConfig.redirectUri)}'
        '&scope=${Uri.encodeComponent(AppConfig.spotifyScopes)}';
  }
}
