import 'dart:convert';

import 'package:hive/hive.dart';

import 'portal_cache_entry.dart';
import 'storage_keys.dart';

class PortalCacheService {
  PortalCacheService({this.maxEntriesPerBox = 50});

  final int maxEntriesPerBox;

  static String scopedKey({
    required String userId,
    required String mediaHouseId,
    required String dataType,
    Map<String, Object?> query = const {},
  }) {
    if (userId.trim().isEmpty || mediaHouseId.trim().isEmpty) {
      throw ArgumentError(
          'Verified user and media-house identity are required.');
    }
    final normalized = query.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    final queryText =
        jsonEncode({for (final item in normalized) item.key: item.value});
    final hash = _fnv1a(queryText).toRadixString(16);
    return '$userId:$mediaHouseId:$dataType:$hash';
  }

  static int _fnv1a(String value) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(value)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  Future<PortalCacheEntry?> read({
    required String boxName,
    required String key,
    required String userId,
    required String mediaHouseId,
  }) async {
    try {
      final box = Hive.box<PortalCacheEntry>(boxName);
      final entry = box.get(key);
      if (entry == null) return null;
      if (entry.schemaVersion != PortalCacheEntry.currentSchemaVersion ||
          entry.cacheKey != key ||
          !entry.belongsTo(userId, mediaHouseId) ||
          entry.isExpired) {
        await box.delete(key);
        return null;
      }
      return entry;
    } catch (_) {
      return null;
    }
  }

  Future<void> write({
    required String boxName,
    required String key,
    required String userId,
    required String mediaHouseId,
    required Map<String, dynamic> payload,
    required Duration ttl,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final box = Hive.box<PortalCacheEntry>(boxName);
      await box.put(
        key,
        PortalCacheEntry(
          schemaVersion: PortalCacheEntry.currentSchemaVersion,
          cacheKey: key,
          userId: userId,
          mediaHouseId: mediaHouseId,
          payload: payload,
          createdAt: now,
          expiresAt: now.add(ttl),
        ),
      );
      await _trim(box);
    } catch (_) {
      // Cache failures must never prevent an API-backed portal flow.
    }
  }

  Future<void> delete(String boxName, String key) async {
    try {
      await Hive.box<PortalCacheEntry>(boxName).delete(key);
    } catch (_) {}
  }

  Future<void> _trim(Box<PortalCacheEntry> box) async {
    if (box.length <= maxEntriesPerBox) return;
    final entries = box.toMap().entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
    final removeCount = box.length - maxEntriesPerBox;
    await box.deleteAll(entries.take(removeCount).map((item) => item.key));
  }
}

abstract final class CacheTtl {
  static const dashboard = Duration(minutes: 3);
  static const transactions = Duration(minutes: 2);
  static const settlements = Duration(minutes: 2);
  static const notifications = Duration(minutes: 1);
  static const profile = Duration(minutes: 10);
  static const support = Duration(minutes: 3);
  static const lookup = Duration(hours: 24);
}

class CacheInvalidationService {
  Future<void> clearAccount(String userId, String mediaHouseId) async {
    for (final boxName in HiveBoxes.all) {
      try {
        final box = Hive.box<PortalCacheEntry>(boxName);
        final keys = box
            .toMap()
            .entries
            .where((item) => item.value.belongsTo(userId, mediaHouseId))
            .map((item) => item.key)
            .toList();
        await box.deleteAll(keys);
      } catch (_) {}
    }
  }

  Future<void> clearAllProtectedCache() async {
    for (final boxName in HiveBoxes.all) {
      try {
        await Hive.box<PortalCacheEntry>(boxName).clear();
      } catch (_) {}
    }
  }
}
