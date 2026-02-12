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
  List<ShortModel>? shorts;
  int? currentPage;

  Data({
    this.totalItems,
    this.totalPages,
    this.pageSize,
    this.shorts,
    this.currentPage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalItems: json["totalItems"],
    totalPages: json["totalPages"],
    pageSize: json["pageSize"],
    shorts: json["shorts"] == null ? [] : List<ShortModel>.from(json["shorts"]!.map((x) => ShortModel.fromJson(x))),
    currentPage: json["currentPage"],
  );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "totalPages": totalPages,
    "pageSize": pageSize,
    "shorts": shorts == null ? [] : List<ShortModel>.from(shorts!.map((x) => x.toJson())),
    "currentPage": currentPage,
  };
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
