import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import 'device_service.dart';

/// HTTP client that signs every request with the device's RSA key.
///
/// Automatically adds the three authentication headers required by the
/// backend: `x-device-id`, `x-timestamp`, and `x-signed-timestamp`.
class ApiClient {
  final DeviceService _device;
  final http.Client _httpClient;

  ApiClient(this._device) : _httpClient = http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = await _device.signTimestamp(timestamp);
    return {
      'x-device-id': _device.deviceId,
      'x-timestamp': timestamp,
      'x-signed-timestamp': signature,
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> get(String path) async {
    return _httpClient.get(
      Uri.parse('${AppConfig.backendUrl}$path'),
      headers: await _authHeaders(),
    );
  }

  Future<http.Response> post(String path,
      {Map<String, dynamic>? body}) async {
    return _httpClient.post(
      Uri.parse('${AppConfig.backendUrl}$path'),
      headers: await _authHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Returns a streamed response for SSE endpoints.
  Future<http.StreamedResponse> getStream(String path) async {
    final request =
        http.Request('GET', Uri.parse('${AppConfig.backendUrl}$path'));
    final authHdrs = await _authHeaders();
    request.headers.addAll(authHdrs);
    request.headers['Accept'] = 'text/event-stream';
    return _httpClient.send(request);
  }
}
