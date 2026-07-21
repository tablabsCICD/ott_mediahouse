import 'package:hive/hive.dart';

class PortalCacheEntry {
  const PortalCacheEntry({
    required this.schemaVersion,
    required this.cacheKey,
    required this.userId,
    required this.mediaHouseId,
    required this.payload,
    required this.createdAt,
    required this.expiresAt,
  });

  static const currentSchemaVersion = 1;
  static const adapterTypeId = 41;

  final int schemaVersion;
  final String cacheKey;
  final String userId;
  final String mediaHouseId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime expiresAt;

  bool get isExpired => !DateTime.now().toUtc().isBefore(expiresAt.toUtc());
  bool belongsTo(String user, String mediaHouse) =>
      userId == user && mediaHouseId == mediaHouse;
}

class PortalCacheEntryAdapter extends TypeAdapter<PortalCacheEntry> {
  @override
  final int typeId = PortalCacheEntry.adapterTypeId;

  @override
  PortalCacheEntry read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var index = 0; index < reader.readByte(); index++)
        reader.readByte(): reader.read(),
    };
    return PortalCacheEntry(
      schemaVersion: fields[0] as int,
      cacheKey: fields[1] as String,
      userId: fields[2] as String,
      mediaHouseId: fields[3] as String,
      payload: Map<String, dynamic>.from(fields[4] as Map),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(fields[5] as int, isUtc: true),
      expiresAt:
          DateTime.fromMillisecondsSinceEpoch(fields[6] as int, isUtc: true),
    );
  }

  @override
  void write(BinaryWriter writer, PortalCacheEntry value) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(value.schemaVersion)
      ..writeByte(1)
      ..write(value.cacheKey)
      ..writeByte(2)
      ..write(value.userId)
      ..writeByte(3)
      ..write(value.mediaHouseId)
      ..writeByte(4)
      ..write(value.payload)
      ..writeByte(5)
      ..write(value.createdAt.toUtc().millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(value.expiresAt.toUtc().millisecondsSinceEpoch);
  }
}
