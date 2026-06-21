import 'package:media_house/domain/entities/user.dart';

class AddUserResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  dynamic totalViews;
  dynamic totalLikes;
  dynamic totalRevenue;
  bool? success;

  AddUserResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.totalViews,
    this.totalLikes,
    this.totalRevenue,
    this.success,
  });

  factory AddUserResponse.fromJson(Map<String, dynamic> json) =>
      AddUserResponse(
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
  ActiveDevice? activeDevice;
  String? sessionId;
  User? user;
  String? token;
  String? accessToken;
  String? refreshToken;
  List<dynamic>? permissions;

  Data({
    this.activeDevice,
    this.sessionId,
    this.user,
    this.token,
    this.accessToken,
    this.refreshToken,
    this.permissions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        activeDevice: json["activeDevice"] == null
            ? null
            : ActiveDevice.fromJson(json["activeDevice"]),
        sessionId: json["sessionId"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        token: json["token"],
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        permissions: json["permissions"] == null
            ? null
            : List<dynamic>.from(json["permissions"]),
      );

  Map<String, dynamic> toJson() => {
        "activeDevice": activeDevice?.toJson(),
        "sessionId": sessionId,
        "user": user?.toJson(),
        "token": token,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "permissions": permissions,
      };
}

class ActiveDevice {
  int? id;
  String? deviceId;
  String? deviceName;
  String? deviceType;
  String? sessionId;
  List<int>? loginTime;
  List<int>? lastAccessTime;
  String? appVersion;

  ActiveDevice({
    this.id,
    this.deviceId,
    this.deviceName,
    this.deviceType,
    this.sessionId,
    this.loginTime,
    this.lastAccessTime,
    this.appVersion,
  });

  factory ActiveDevice.fromJson(Map<String, dynamic> json) => ActiveDevice(
        id: json["id"],
        deviceId: json["deviceId"],
        deviceName: json["deviceName"],
        deviceType: json["deviceType"],
        sessionId: json["sessionId"],
        loginTime: json["loginTime"] == null
            ? []
            : List<int>.from(json["loginTime"]!.map((x) => x)),
        lastAccessTime: json["lastAccessTime"] == null
            ? []
            : List<int>.from(json["lastAccessTime"]!.map((x) => x)),
        appVersion: json["appVersion"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "deviceId": deviceId,
        "deviceName": deviceName,
        "deviceType": deviceType,
        "sessionId": sessionId,
        "loginTime": loginTime == null
            ? []
            : List<dynamic>.from(loginTime!.map((x) => x)),
        "lastAccessTime": lastAccessTime == null
            ? []
            : List<dynamic>.from(lastAccessTime!.map((x) => x)),
        "appVersion": appVersion,
      };
}
