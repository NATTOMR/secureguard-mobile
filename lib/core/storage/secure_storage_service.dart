import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _authTokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
