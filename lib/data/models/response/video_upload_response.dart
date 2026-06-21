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
  int? duration;
  String? fileName;
  int? size;
  String? fullUrl;
  int? width;
  String? format;
  String? status;
  int? height;

  Data({
    this.duration,
    this.fileName,
    this.size,
    this.fullUrl,
    this.width,
    this.format,
    this.status,
    this.height,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        duration: _toInt(json["duration"]),
        fileName: json["fileName"],
        size: json["size"],
        fullUrl: json["fullUrl"] ??
            json["videoUrl"] ??
            json["fileUrl"] ??
            json["url"],
        width: json["width"],
        format: json["format"],
        status: json["status"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "duration": duration,
        "fileName": fileName,
        "size": size,
        "fullUrl": fullUrl,
        "width": width,
        "format": format,
        "status": status,
        "height": height,
      };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
