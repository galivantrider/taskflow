import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessTokenExpiryKey = 'access_token_expiry';

  final FlutterSecureStorage _storage;

const SecureStorageService({
  this._storage = const FlutterSecureStorage(),
});

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );

    await _storage.write(
      key: _accessTokenExpiryKey,
      value: accessTokenExpiry.toIso8601String(),
    );
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<DateTime?> getAccessTokenExpiry() async {
    final value = await _storage.read(
      key: _accessTokenExpiryKey,
    );

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiryKey);
  }
}