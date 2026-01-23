import '../../../domain/entities/content.dart';

class SeriesResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  SeriesResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory SeriesResponse.fromJson(Map<String, dynamic> json) => SeriesResponse(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    statusCode: json["statusCode"],
    total: json["total"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "statusCode": statusCode,
    "total": total,
    "success": success,
  };
}

class Data {
  int? totalPages;
  bool? hasPrevious;
  bool? hasNext;
  int? currentPage;
  List<Content>? contentList;
  int? totalElements;

  Data({
    this.totalPages,
    this.hasPrevious,
    this.hasNext,
    this.currentPage,
    this.contentList,
    this.totalElements,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalPages: json["totalPages"],
    hasPrevious: json["hasPrevious"],
    hasNext: json["hasNext"],
    currentPage: json["currentPage"],
    contentList: json["contentList"] == null ? [] : List<Content>.from(json["contentList"]!.map((x) => Content.fromJson(x))),
    totalElements: json["totalElements"],
  );

  Map<String, dynamic> toJson() => {
    "totalPages": totalPages,
    "hasPrevious": hasPrevious,
    "hasNext": hasNext,
    "currentPage": currentPage,
    "contentList": contentList == null ? [] : List<dynamic>.from(contentList!.map((x) => x.toJson())),
    "totalElements": totalElements,
  };
}