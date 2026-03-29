import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';
import 'api_client.dart';

/// Implements [AuthRepository] by launching an OAuth browser flow,
/// capturing the authorization code, and sending it to the backend
/// for token exchange.
class BackendAuthService implements AuthRepository {
  final ApiClient _api;

  BackendAuthService(this._api);

  @override
  Future<void> authorize(String platformId) async {
    final authUrl = _buildAuthUrl(platformId);

    // Launch browser and capture redirect with auth code.
    final resultUrl = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'pullrequest',
    );

    final code = Uri.parse(resultUrl).queryParameters['code'];
    if (code == null) {
      throw AuthException('No authorization code received');
    }

    print("}}}}");

    // Send code to backend for token exchange.
    final response = await _api.post('/oauth/register_code', body: {
      'platform': platformId,
      'code': code,
    });

    if (response.statusCode != 200) {
      throw AuthException(
        'Failed to register authorization (${response.statusCode})',
      );
    }
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

  String _buildAuthUrl(String platformId) {
    if (platformId == 'spotify') {
      return 'https://accounts.spotify.com/authorize?'
          'client_id=${AppConfig.spotifyClientId}'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(AppConfig.redirectUri)}'
          '&scope=${Uri.encodeComponent(AppConfig.spotifyScopes)}';
    } else {
      return 'https://accounts.google.com/o/oauth2/v2/auth?'
          'client_id=${AppConfig.googleClientId}'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(AppConfig.redirectUri)}'
          '&scope=${Uri.encodeComponent(AppConfig.googleScopes)}'
          '&access_type=offline'
          '&prompt=consent';
    }
  }
}
