import 'package:flutter_test/flutter_test.dart';
import 'package:media_house/app/core/storage/portal_cache_entry.dart';
import 'package:media_house/app/core/storage/portal_cache_service.dart';
import 'package:media_house/app/core/storage/preferences_service.dart';
import 'package:media_house/app/core/storage/secure_session_service.dart';
import 'package:media_house/app/core/storage/storage_keys.dart';
import 'package:media_house/app/core/storage/storage_migration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MemorySecureSession implements SecureSessionService {
  String? access;
  String? refresh;
  String? session;
  bool failWrites = false;

  @override
  Future<void> clearSession() async => access = refresh = session = null;
  @override
  Future<String?> getAccessToken() async => access;
  @override
  Future<String?> getRefreshToken() async => refresh;
  @override
  Future<String?> getSessionId() async => session;
  @override
  Future<void> setAccessToken(String value) async {
    if (failWrites) throw StateError('unavailable');
    access = value;
  }

  @override
  Future<void> setRefreshToken(String value) async => refresh = value;
  @override
  Future<void> setSessionId(String value) async => session = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('preferences', () {
    test('typed defaults and legacy theme survive migration', () async {
      SharedPreferences.setMockInitialValues({'isDark': false});
      final service = await PreferencesService.create();
      expect(service.isDarkMode, isFalse);
      expect(service.selectedLanguage, 'en');
      expect(service.tablePageSize, 10);
      await service.setDarkMode(true);
      expect(service.isDarkMode, isTrue);
    });
  });

  group('secure migration', () {
    test('migrates, verifies, retains legacy value, and is idempotent',
        () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.legacyAccessToken: 'legacy-access',
        StorageKeys.legacyRefreshToken: 'legacy-refresh',
      });
      final preferences = await PreferencesService.create();
      final secure = MemorySecureSession();
      final migration = StorageMigrationService(preferences, secure);
      await migration.migrate();
      await migration.migrate();
      expect(secure.access, 'legacy-access');
      expect(secure.refresh, 'legacy-refresh');
      expect(preferences.getString(StorageKeys.legacyAccessToken),
          'legacy-access');
      expect(preferences.migrationVersion, 1);
    });

    test('failed secure write leaves migration incomplete and legacy intact',
        () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.legacyAccessToken: 'legacy-access',
      });
      final preferences = await PreferencesService.create();
      final secure = MemorySecureSession()..failWrites = true;
      await StorageMigrationService(preferences, secure).migrate();
      expect(preferences.migrationVersion, 0);
      expect(preferences.getString(StorageKeys.legacyAccessToken),
          'legacy-access');
    });

    test('password, OTP, bank and KYC fields are removed from legacy hints',
        () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.legacyAccessToken: 'legacy-access',
        'loggedUser': jsonEncode({
          'id': 7,
          'firstName': 'User',
          'role': ['MediaHouse'],
          'password': 'must-not-remain',
          'otp': '123456',
        }),
        'MediaHouse': jsonEncode({
          'id': 9,
          'mediaHouseName': 'House',
          'bankAccountNumber': '1234',
          'panCard': 'ABCDE1234F',
          'gstCertificates': 'signed-url',
        }),
      });
      final preferences = await PreferencesService.create();
      await StorageMigrationService(preferences, MemorySecureSession())
          .migrate();
      final user = jsonDecode(preferences.getString('loggedUser')!) as Map;
      final mediaHouse =
          jsonDecode(preferences.getString('MediaHouse')!) as Map;
      expect(user, isNot(contains('password')));
      expect(user, isNot(contains('otp')));
      expect(mediaHouse, isNot(contains('bankAccountNumber')));
      expect(mediaHouse, isNot(contains('panCard')));
      expect(mediaHouse, isNot(contains('gstCertificates')));
    });
  });

  group('cache model', () {
    test('adapter id is reserved and expiry uses UTC', () {
      expect(PortalCacheEntry.adapterTypeId, 41);
      final now = DateTime.now().toUtc();
      final entry = PortalCacheEntry(
        schemaVersion: PortalCacheEntry.currentSchemaVersion,
        cacheKey: '1:2:dashboard:a',
        userId: '1',
        mediaHouseId: '2',
        payload: const {'safe': true},
        createdAt: now.subtract(const Duration(minutes: 2)),
        expiresAt: now.subtract(const Duration(seconds: 1)),
      );
      expect(entry.isExpired, isTrue);
      expect(entry.belongsTo('1', '2'), isTrue);
      expect(entry.belongsTo('1', '3'), isFalse);
    });

    test('query parameters and identities cannot collide', () {
      final first = PortalCacheService.scopedKey(
        userId: '1',
        mediaHouseId: '2',
        dataType: 'transactions',
        query: const {'page': 0, 'size': 10, 'status': 'PAID'},
      );
      final reordered = PortalCacheService.scopedKey(
        userId: '1',
        mediaHouseId: '2',
        dataType: 'transactions',
        query: const {'status': 'PAID', 'size': 10, 'page': 0},
      );
      final otherAccount = PortalCacheService.scopedKey(
        userId: '1',
        mediaHouseId: '3',
        dataType: 'transactions',
        query: const {'page': 0, 'size': 10, 'status': 'PAID'},
      );
      expect(first, reordered);
      expect(first, isNot(otherAccount));
    });
  });
}
