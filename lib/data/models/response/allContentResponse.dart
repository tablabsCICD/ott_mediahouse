import 'package:media_house/domain/entities/content.dart';

class AllContentResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  AllContentResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory AllContentResponse.fromJson(Map<String, dynamic> json) =>
      AllContentResponse(
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
  int? totalItems;
  List<Content>? contentList;
  int? totalPages;
  int? pageSize;
  int? currentPage;

  Data({
    this.totalItems,
    this.contentList,
    this.totalPages,
    this.pageSize,
    this.currentPage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalItems: json["totalItems"],
        contentList: json["ContentList"] == null && json["contentList"] == null
            ? []
            : List<Content>.from(
                (json["ContentList"] ?? json["contentList"])
                    .map((x) => Content.fromJson(x)),
              ),
        totalPages: json["totalPages"],
        pageSize: json["pageSize"],
        currentPage: json["currentPage"],
      );

  Map<String, dynamic> toJson() => {
        "totalItems": totalItems,
        "ContentList": contentList == null
            ? []
            : List<dynamic>.from(contentList!.map((x) => x.toJson())),
        "totalPages": totalPages,
        "pageSize": pageSize,
        "currentPage": currentPage,
      };
}
