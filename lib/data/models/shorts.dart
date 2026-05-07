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

  factory ShortMasterResponse.fromJson(Map<String, dynamic> json) =>
      ShortMasterResponse(
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
  List<ShortModel>? miniSeries;
  int? totalPages;
  int? pageSize;
  bool? hasPrevious;
  bool? hasNext;
  int? currentPage;

  Data({
    this.totalItems,
    this.miniSeries,
    this.totalPages,
    this.pageSize,
    this.hasPrevious,
    this.hasNext,
    this.currentPage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalItems: json["totalItems"],
        miniSeries: json["miniSeries"] == null
            ? []
            : List<ShortModel>.from(
                json["miniSeries"]!.map((x) => ShortModel.fromJson(x))),
        totalPages: json["totalPages"],
        pageSize: json["pageSize"],
        hasPrevious: json["hasPrevious"],
        hasNext: json["hasNext"],
        currentPage: json["currentPage"],
      );

  Map<String, dynamic> toJson() => {
        "totalItems": totalItems,
        "miniSeries": miniSeries == null
            ? []
            : List<dynamic>.from(miniSeries!.map((x) => x.toJson())),
        "totalPages": totalPages,
        "pageSize": pageSize,
        "hasPrevious": hasPrevious,
        "hasNext": hasNext,
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
  List<dynamic>? castList;
  List<String>? crewList;
  int? uploadDateTime;
  String? approvalStatus;
  int? approvedDateTime;
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
    this.castList,
    this.crewList,
    this.uploadDateTime,
    this.approvalStatus,
    this.approvedDateTime,
    this.languageList,
  });

  factory ShortModel.fromJson(Map<String, dynamic> json) => ShortModel(
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
        castList: json["castList"] == null
            ? []
            : List<dynamic>.from(json["castList"]!.map((x) => x)),
        crewList: json["crewList"] == null
            ? []
            : List<String>.from(json["crewList"]!.map((x) => x)),
        uploadDateTime: json["uploadDateTime"],
        approvalStatus: json["approvalStatus"],
        approvedDateTime: json["approvedDateTime"],
        languageList: json["languageList"] == null
            ? []
            : List<LanguageList>.from(
                json["languageList"]!.map((x) => LanguageList.fromJson(x))),
      );

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
        "castList":
            castList == null ? [] : List<dynamic>.from(castList!.map((x) => x)),
        "crewList":
            crewList == null ? [] : List<dynamic>.from(crewList!.map((x) => x)),
        "uploadDateTime": uploadDateTime,
        "approvalStatus": approvalStatus,
        "approvedDateTime": approvedDateTime,
        "languageList": languageList == null
            ? []
            : List<dynamic>.from(languageList!.map((x) => x.toJson())),
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
