import 'dart:convert';

import 'local_data_sanitizer.dart';
import 'preferences_service.dart';
import 'secure_session_service.dart';
import 'storage_keys.dart';

class StorageMigrationService {
  StorageMigrationService(this._preferences, this._secureSession);

  final PreferencesService _preferences;
  final SecureSessionService _secureSession;

  Future<void> migrate() async {
    await _sanitizeLegacyDisplayHints();
    final accessComplete = await _migrateValue(
      completeKey: StorageKeys.accessTokenMigrationComplete,
      secureRead: _secureSession.getAccessToken,
      secureWrite: _secureSession.setAccessToken,
      legacyKeys: const [
        StorageKeys.legacyAccessToken,
        StorageKeys.legacyToken,
      ],
    );
    final refreshComplete = await _migrateValue(
      completeKey: StorageKeys.refreshTokenMigrationComplete,
      secureRead: _secureSession.getRefreshToken,
      secureWrite: _secureSession.setRefreshToken,
      legacyKeys: const [StorageKeys.legacyRefreshToken],
      optional: true,
    );
    final sessionComplete = await _migrateValue(
      completeKey: StorageKeys.sessionIdMigrationComplete,
      secureRead: _secureSession.getSessionId,
      secureWrite: _secureSession.setSessionId,
      legacyKeys: const [StorageKeys.legacySessionId],
      optional: true,
    );
    if (accessComplete && refreshComplete && sessionComplete) {
      await _preferences
          .setMigrationVersion(StorageKeys.currentMigrationVersion);
    }
  }

  Future<void> _sanitizeLegacyDisplayHints() async {
    await _sanitizeJson(
      'loggedUser',
      LocalDataSanitizer.userDisplayHint,
    );
    await _sanitizeJson(
      'MediaHouse',
      LocalDataSanitizer.mediaHouseDisplayHint,
    );
  }

  Future<void> _sanitizeJson(
    String key,
    Map<String, dynamic> Function(Map<String, dynamic>) sanitizer,
  ) async {
    try {
      final raw = _preferences.getString(key);
      if (raw == null || raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      await _preferences.setString(
        key,
        jsonEncode(sanitizer(Map<String, dynamic>.from(decoded))),
      );
    } catch (_) {
      // Malformed legacy data is left untouched for backend recovery.
    }
  }

  Future<bool> _migrateValue({
    required String completeKey,
    required Future<String?> Function() secureRead,
    required Future<void> Function(String) secureWrite,
    required List<String> legacyKeys,
    bool optional = false,
  }) async {
    try {
      final existing = await secureRead();
      if (_valid(existing)) {
        await _preferences.setBool(completeKey, true);
        return true;
      }
      String? legacy;
      for (final key in legacyKeys) {
        final candidate = _preferences.getString(key);
        if (_valid(candidate)) {
          legacy = candidate;
          break;
        }
      }
      if (!_valid(legacy)) {
        if (optional) await _preferences.setBool(completeKey, true);
        return optional;
      }
      await secureWrite(legacy!);
      final verified = await secureRead();
      if (verified != legacy) return false;
      await _preferences.setBool(completeKey, true);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _valid(String? value) => value != null && value.trim().isNotEmpty;
}
