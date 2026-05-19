class VideoUploadResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  dynamic totalViews;
  dynamic totalLikes;
  dynamic totalRevenue;
  bool? success;

  VideoUploadResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.totalViews,
    this.totalLikes,
    this.totalRevenue,
    this.success,
  });

  factory VideoUploadResponse.fromJson(Map<String, dynamic> json) =>
      VideoUploadResponse(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        statusCode: json["statusCode"],
        total: json["total"],
        totalViews: json["totalViews"],
        totalLikes: json["totalLikes"],
        totalRevenue: json["totalRevenue"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "statusCode": statusCode,
        "total": total,
        "totalViews": totalViews,
        "totalLikes": totalLikes,
        "totalRevenue": totalRevenue,
        "success": success,
      };
}

class Data {
  String? fileName;
  String? videoUrl;
  int? duration;
  int? width;
  int? height;
  String? format;
  int? size;

  Data({
    this.fileName,
    this.videoUrl,
    this.duration,
    this.width,
    this.height,
    this.format,
    this.size,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        fileName: json["fileName"],
        videoUrl: json["fullUrl"],
        duration: json["duration"],
        width: json["width"],
        height: json["height"],
        format: json["format"],
        size: json["size"],
      );

  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "fullUrl": videoUrl,
        "duration": duration,
        "width": width,
        "height": height,
        "format": format,
        "size": size,
      };
}
