class MediaHouseDashboardCount {
  MediaHouseDashboardData? data;
  String? message;
  int? statusCode;
  bool? isSuccess;

  MediaHouseDashboardCount({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
  });

  factory MediaHouseDashboardCount.fromJson(Map<String, dynamic> json) =>
      MediaHouseDashboardCount(
        data: json["data"] == null
            ? null
            : MediaHouseDashboardData.fromJson(json["data"]),
        message: json["message"],
        statusCode: json["statusCode"],
        isSuccess: json["isSuccess"] == true || json["success"] == true,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "message": message,
        "statusCode": statusCode,
        "isSuccess": isSuccess,
      };
}

class MediaHouseDashboardData {
  int? approvedContent;
  int? upcomingContentCount;
  int? totalViews;
  double? viewRevenue;
  int? pendingContentCount;
  int? rejectedContentCount;

  MediaHouseDashboardData({
    this.approvedContent,
    this.upcomingContentCount,
    this.totalViews,
    this.viewRevenue,
    this.pendingContentCount,
    this.rejectedContentCount,
  });

  factory MediaHouseDashboardData.fromJson(Map<String, dynamic> json) =>
      MediaHouseDashboardData(
        approvedContent: _readInt(json["Approved Content"]),
        upcomingContentCount: _readInt(json["Upcoming Content Count"]),
        totalViews: _readInt(json["totalViews"]),
        viewRevenue: _readDouble(json["viewRevenue"]),
        pendingContentCount: _readInt(json["Pending Content Count"]),
        rejectedContentCount: _readInt(json["Rejected Content Count"]),
      );

  Map<String, dynamic> toJson() => {
        "Approved Content": approvedContent,
        "Upcoming Content Count": upcomingContentCount,
        "totalViews": totalViews,
        "viewRevenue": viewRevenue,
        "Pending Content Count": pendingContentCount,
        "Rejected Content Count": rejectedContentCount,
      };
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
