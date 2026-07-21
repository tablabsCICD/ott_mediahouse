import 'package:hive_flutter/hive_flutter.dart';

import 'portal_cache_entry.dart';
import 'portal_cache_service.dart';
import 'preferences_service.dart';
import 'secure_session_service.dart';
import 'storage_keys.dart';
import 'storage_migration_service.dart';

class StorageService {
  StorageService._({
    required this.preferences,
    required this.secureSession,
    required this.portalCache,
    required this.cacheInvalidation,
    required this.cacheAvailable,
  });

  static StorageService? _instance;

  final PreferencesService preferences;
  final SecureSessionService secureSession;
  final PortalCacheService portalCache;
  final CacheInvalidationService cacheInvalidation;
  final bool cacheAvailable;

  static StorageService get instance {
    final value = _instance;
    if (value == null) throw StateError('StorageService is not initialized.');
    return value;
  }

  static Future<StorageService> initialize() async {
    if (_instance != null) return _instance!;
    final preferences = await PreferencesService.create();
    final secureSession = FlutterSecureSessionService();
    var cacheAvailable = false;
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(PortalCacheEntry.adapterTypeId)) {
        Hive.registerAdapter(PortalCacheEntryAdapter());
      }
      for (final boxName in HiveBoxes.all) {
        await Hive.openBox<PortalCacheEntry>(boxName);
      }
      cacheAvailable = true;
    } catch (_) {
      cacheAvailable = false;
    }
    await StorageMigrationService(preferences, secureSession).migrate();
    return _instance = StorageService._(
      preferences: preferences,
      secureSession: secureSession,
      portalCache: PortalCacheService(),
      cacheInvalidation: CacheInvalidationService(),
      cacheAvailable: cacheAvailable,
    );
  }
}
