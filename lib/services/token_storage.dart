import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_constants.dart';

abstract class TokenStorage {
  Future<String?> readToken();

  Future<void> writeToken(String token);

  Future<void> deleteToken();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() {
    return _storage.read(key: AppConstants.authTokenKey);
  }

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: AppConstants.authTokenKey, value: token);
  }

  @override
  Future<void> deleteToken() {
    return _storage.delete(key: AppConstants.authTokenKey);
  }
}

class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }
}
