class ContentImageUploadResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  ContentImageUploadResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory ContentImageUploadResponse.fromJson(Map<String, dynamic> json) => ContentImageUploadResponse(
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
  String? videoId;
  String? thumbnailUrl;

  Data({
    this.videoId,
    this.thumbnailUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    videoId: json["videoId"],
    thumbnailUrl: json["thumbnailUrl"],
  );

  Map<String, dynamic> toJson() => {
    "videoId": videoId,
    "thumbnailUrl": thumbnailUrl,
  };
}
