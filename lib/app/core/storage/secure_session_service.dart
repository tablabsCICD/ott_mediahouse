import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_keys.dart';

abstract interface class SecureSessionService {
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String value);
  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String value);
  Future<String?> getSessionId();
  Future<void> setSessionId(String value);
  Future<void> clearSession();
}

class FlutterSecureSessionService implements SecureSessionService {
  FlutterSecureSessionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String? _valid(String? value) =>
      value != null && value.trim().isNotEmpty ? value : null;

  @override
  Future<String?> getAccessToken() async =>
      _valid(await _storage.read(key: StorageKeys.accessToken));

  @override
  Future<void> setAccessToken(String value) =>
      _write(StorageKeys.accessToken, value);

  @override
  Future<String?> getRefreshToken() async =>
      _valid(await _storage.read(key: StorageKeys.refreshToken));

  @override
  Future<void> setRefreshToken(String value) =>
      _write(StorageKeys.refreshToken, value);

  @override
  Future<String?> getSessionId() async =>
      _valid(await _storage.read(key: StorageKeys.sessionId));

  @override
  Future<void> setSessionId(String value) =>
      _write(StorageKeys.sessionId, value);

  Future<void> _write(String key, String value) async {
    if (value.trim().isEmpty) throw ArgumentError.value(value, key);
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
      _storage.delete(key: StorageKeys.sessionId),
    ]);
  }
}
