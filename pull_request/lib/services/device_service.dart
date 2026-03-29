import 'dart:convert';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

/// Manages device identity via RSA keypair and backend registration.
///
/// On first launch, generates an RSA-2048 keypair, registers the public
/// key with `POST /register`, and stores the private key + device_id
/// in secure storage. Subsequent launches load from storage.
class DeviceService {
  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'device_id';
  static const _privateKeyKey = 'private_key';

  String? _deviceId;
  String? _privateKey;

  String get deviceId => _deviceId!;
  bool get isRegistered => _deviceId != null && _privateKey != null;

  /// Initializes the device identity. Must be called before any API calls.
  Future<void> init() async {
    _deviceId = await _storage.read(key: _deviceIdKey);
    _privateKey = await _storage.read(key: _privateKeyKey);

    if (_deviceId == null || _privateKey == null) {
      await _register();
    }
  }

  Future<void> _register() async {
    final keyPair = await RSA.generate(2048);

    final response = await http.post(
      Uri.parse('${AppConfig.backendUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'public_key': keyPair.publicKey}),
    );

    if (response.statusCode != 200) {
      throw Exception('Device registration failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _deviceId = data['device_id'] as String;
    _privateKey = keyPair.privateKey;

    await _storage.write(key: _deviceIdKey, value: _deviceId);
    await _storage.write(key: _privateKeyKey, value: _privateKey);
  }

  /// Signs [timestamp] with the device's RSA private key using SHA-256.
  /// Returns a base64-encoded PKCS#1 v1.5 signature.
  Future<String> signTimestamp(String timestamp) async {
    return RSA.signPKCS1v15(timestamp, Hash.SHA256, _privateKey!);
  }
}
