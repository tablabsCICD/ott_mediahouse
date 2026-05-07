import '../../../domain/entities/content.dart';

class ShortDetailResponse {
  String? message;
  ShortDetailModel? data;
  bool? success;

  ShortDetailResponse({
    this.message,
    this.data,
    this.success,
  });

  factory ShortDetailResponse.fromJson(Map<String, dynamic> json) => ShortDetailResponse(
    message: json["message"],
    data: json["data"] == null ? null : ShortDetailModel.fromJson(json["data"]),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "success": success,
  };
}

class ShortDetailModel {
  int? id;
  String? title;
  String? description;
  String? poster;
  int? totalParts;
  int? coinsPerPart;
  String? creatorName;
  int? viewCount;
  int? likeCount;
  bool? isTrending;
  String? category;
  String? rentlDuration;
  List<LanguageList>? languageList;
  List<dynamic>? tags;
  List<ShortPartModel>? parts;
  bool? trending;

  ShortDetailModel({
    this.id,
    this.title,
    this.description,
    this.poster,
    this.totalParts,
    this.coinsPerPart,
    this.creatorName,
    this.viewCount,
    this.likeCount,
    this.isTrending,
    this.category,
    this.rentlDuration,
    this.languageList,
    this.tags,
    this.parts,
    this.trending,
  });

  factory ShortDetailModel.fromJson(Map<String, dynamic> json) => ShortDetailModel(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    poster: json["poster"],
    totalParts: json["totalParts"],
    coinsPerPart: json["coinsPerPart"],
    creatorName: json["creatorName"],
    viewCount: json["viewCount"],
    likeCount: json["likeCount"],
    isTrending: json["isTrending"],
    category: json["category"],
    rentlDuration: json["rentlDuration"],
    languageList: json["languageList"] == null
        ? []
        : List<LanguageList>.from(
            json["languageList"]!.map((x) => LanguageList.fromJson(x)),
          ),
    tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
    parts: json["parts"] == null ? [] : List<ShortPartModel>.from(json["parts"]!.map((x) => ShortPartModel.fromJson(x))),
    trending: json["trending"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "poster": poster,
    "totalParts": totalParts,
    "coinsPerPart": coinsPerPart,
    "creatorName": creatorName,
    "viewCount": viewCount,
    "likeCount": likeCount,
    "isTrending": isTrending,
    "category": category,
    "rentlDuration": rentlDuration,
    "languageList": languageList == null
        ? []
        : List<dynamic>.from(languageList!.map((x) => x.toJson())),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "parts": parts == null ? [] : List<dynamic>.from(parts!.map((x) => x.toJson())),
    "trending": trending,
  };
}

class ShortPartModel {
  String? partId;
  int? partNumber;
  String? title;
  int? coins;
  bool? isLocked;
  bool? isPurchased;
  String? videoUrl;
  String? thumbnail;
  int? durationSec;
  int? views;
  int? likes;
  String? nextPartId;
  bool? autoPlayNext;
  bool? isFreePreview;
  bool? isLiked;
  bool? freePreview;
  bool? purchased;
  bool? liked;
  bool? locked;

  ShortPartModel({
    this.partId,
    this.partNumber,
    this.title,
    this.coins,
    this.isLocked,
    this.isPurchased,
    this.videoUrl,
    this.thumbnail,
    this.durationSec,
    this.views,
    this.likes,
    this.nextPartId,
    this.autoPlayNext,
    this.isFreePreview,
    this.isLiked,
    this.freePreview,
    this.purchased,
    this.liked,
    this.locked,
  });

  factory ShortPartModel.fromJson(Map<String, dynamic> json) => ShortPartModel(
    partId: json["partId"],
    partNumber: json["partNumber"],
    title: json["title"],
    coins: json["coins"],
    isLocked: json["isLocked"],
    isPurchased: json["isPurchased"],
    videoUrl: json["videoUrl"],
    thumbnail: json["thumbnail"],
    durationSec: json["durationSec"],
    views: json["views"],
    likes: json["likes"],
    nextPartId: json["nextPartId"],
    autoPlayNext: json["autoPlayNext"],
    isFreePreview: json["isFreePreview"],
    isLiked: json["isLiked"],
    freePreview: json["freePreview"],
    purchased: json["purchased"],
    liked: json["liked"],
    locked: json["locked"],
  );

  Map<String, dynamic> toJson() => {
    "partId": partId,
    "partNumber": partNumber,
    "title": title,
    "coins": coins,
    "isLocked": isLocked,
    "isPurchased": isPurchased,
    "videoUrl": videoUrl,
    "thumbnail": thumbnail,
    "durationSec": durationSec,
    "views": views,
    "likes": likes,
    "nextPartId": nextPartId,
    "autoPlayNext": autoPlayNext,
    "isFreePreview": isFreePreview,
    "isLiked": isLiked,
    "freePreview": freePreview,
    "purchased": purchased,
    "liked": liked,
    "locked": locked,
  };
}
