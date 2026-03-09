import '../../domain/entities/content.dart';

class ShortMasterResponse {
  String? message;
  Data? data;
  bool? success;

  ShortMasterResponse({
    this.message,
    this.data,
    this.success,
  });

  factory ShortMasterResponse.fromJson(Map<String, dynamic> json) => ShortMasterResponse(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "success": success,
  };
}

class Data {
  int? totalItems;
  int? totalPages;
  int? pageSize;
  bool? hasPrevious;
  bool? hasNext;
  List<ShortModel>? shorts;
  int? currentPage;

  Data({
    this.totalItems,
    this.totalPages,
    this.pageSize,
    this.hasPrevious,
    this.hasNext,
    this.shorts,
    this.currentPage,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    final shortItems = _extractShortItems(json);
    final normalizedShortItems = shortItems
        .map((item) {
          if (item is Map<String, dynamic>) return item;
          if (item is Map) return Map<String, dynamic>.from(item);
          return <String, dynamic>{};
        })
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return Data(
      totalItems: _asInt(json["totalItems"]) ??
          _asInt(json["totalElements"]) ??
          _asInt(json["numberOfElements"]) ??
          normalizedShortItems.length,
      totalPages: _asInt(json["totalPages"]) ?? 1,
      pageSize:
          _asInt(json["pageSize"]) ??
              _asInt(json["size"]) ??
              normalizedShortItems.length,
      hasPrevious: json["hasPrevious"],
      hasNext: json["hasNext"],
      shorts: normalizedShortItems.map(ShortModel.fromJson).toList(),
      currentPage: _asInt(json["currentPage"]) ??
          _asInt(json["number"]) ??
          _asInt(json["pageNumber"]) ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "totalPages": totalPages,
    "pageSize": pageSize,
    "hasPrevious": hasPrevious,
    "hasNext": hasNext,
    "shorts": shorts == null ? [] : List<ShortModel>.from(shorts!.map((x) => x.toJson())),
    "currentPage": currentPage,
  };

  static List<dynamic> _extractShortItems(Map<String, dynamic> json) {
    final rawList = json["shorts"] ?? json["content"];
    if (rawList is List) return List<dynamic>.from(rawList);
    return const <dynamic>[];
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class ShortModel {
  int? id;
  String? title;
  String? description;
  String? posterUrl;
  int? totalParts;
  int? coinsPerPart;
  String? creatorName;
  int? viewCount;
  int? likeCount;
  bool? isTrending;
  String? category;
  int? mediaHouseId;
  String? rentlDuration;
  dynamic createdAt;
  dynamic createdDate;
  List<LanguageList>? languageList;

  ShortModel({
    this.id,
    this.title,
    this.description,
    this.posterUrl,
    this.totalParts,
    this.coinsPerPart,
    this.creatorName,
    this.viewCount,
    this.likeCount,
    this.isTrending,
    this.category,
    this.mediaHouseId,
    this.rentlDuration,
    this.createdAt,
    this.createdDate,
    this.languageList,
  });

  factory ShortModel.fromJson(Map<String, dynamic> json) {
    return ShortModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      posterUrl: json["posterUrl"],
      totalParts: json["totalParts"],
      coinsPerPart: json["coinsPerPart"],
      creatorName: json["creatorName"],
      viewCount: json["viewCount"],
      likeCount: json["likeCount"],
      isTrending: json["isTrending"],
      category: json["category"],
      mediaHouseId: json["mediaHouseId"],
      rentlDuration: json["rentlDuration"],
      createdAt: json["createdAt"],
      createdDate: json["createdDate"],
      languageList: json["languageList"] == null ? [] : List<LanguageList>.from(json["languageList"]!.map((x) => LanguageList.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "posterUrl": posterUrl,
    "totalParts": totalParts,
    "coinsPerPart": coinsPerPart,
    "creatorName": creatorName,
    "viewCount": viewCount,
    "likeCount": likeCount,
    "isTrending": isTrending,
    "category": category,
    "mediaHouseId": mediaHouseId,
    "rentlDuration": rentlDuration,
    "createdAt": createdAt,
    "createdDate": createdDate,
    "languageList": languageList == null ? [] : List<dynamic>.from(languageList!.map((x) => x.toJson())),
  };
}

class ShortDetailModel {
  final int id;
  final String title;
  final String description;
  final String poster;
  final int totalParts;
  final String creatorName;
  final List<ShortPart> parts;

  ShortDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.poster,
    required this.totalParts,
    required this.creatorName,
    required this.parts,
  });

  factory ShortDetailModel.fromJson(Map<String, dynamic> json) {
    return ShortDetailModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      poster: json["poster"] ?? "",
      totalParts: json["totalParts"],
      creatorName: json["creatorName"],
      parts: (json["parts"] as List).map((e) => ShortPart.fromJson(e)).toList(),
    );
  }
}

class ShortPart {
  final String partId;
  final int partNumber;
  final String title;
  final String videoUrl;
  final String thumbnail;
  final int durationSec;
  final bool locked;
  final bool purchased;

  ShortPart({
    required this.partId,
    required this.partNumber,
    required this.title,
    required this.videoUrl,
    required this.thumbnail,
    required this.durationSec,
    required this.locked,
    required this.purchased,
  });

  factory ShortPart.fromJson(Map<String, dynamic> json) {
    return ShortPart(
      partId: json["partId"].toString(),
      partNumber: json["partNumber"],
      title: json["title"],
      videoUrl: json["videoUrl"],
      thumbnail: json["thumbnail"],
      durationSec: json["durationSec"],
      locked: json["locked"] ?? false,
      purchased: json["purchased"] ?? false,
    );
  }
}
