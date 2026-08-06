import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  static const String _authTokenKey = 'auth_token';

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
