class AudioUploadResponse {
  String? message;
  AudioUploadData? data;
  int? statusCode;
  bool? success;

  AudioUploadResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory AudioUploadResponse.fromJson(Map<String, dynamic> json) =>
      AudioUploadResponse(
        message: json["message"],
        data: json["data"] == null
            ? null
            : AudioUploadData.fromJson(json["data"]),
        statusCode: json["statusCode"],
        success: json["success"],
      );
}

class AudioUploadData {
  String? fileName;
  String? fullUrl;
  int? duration;
  String? format;
  int? size;
  int? bitRate;
  int? sampleRate;
  int? channel;

  AudioUploadData({
    this.fileName,
    this.fullUrl,
    this.duration,
    this.format,
    this.size,
    this.bitRate,
    this.sampleRate,
    this.channel,
  });

  factory AudioUploadData.fromJson(Map<String, dynamic> json) =>
      AudioUploadData(
        fileName: json["fileName"],
        fullUrl: json["fullUrl"],
        duration: json["duration"],
        format: json["format"],
        size: json["size"],
        bitRate: json["bitRate"],
        sampleRate: json["sampleRate"],
        channel: json["channel"],
      );
}
