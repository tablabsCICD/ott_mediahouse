class ChartResponse {
  String? message;
  List<Datum>? data;
  int? statusCode;
  bool? success;

  ChartResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory ChartResponse.fromJson(Map<String, dynamic> json) => ChartResponse(
        message: json["message"]?.toString(),
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        statusCode: json["statusCode"] is int
            ? json["statusCode"] as int
            : int.tryParse(json["statusCode"]?.toString() ?? ''),
        success: json["success"] == null
            ? (json["isSuccess"] == true)
            : (json["success"] == true),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "statusCode": statusCode,
    "success": success,
  };
}

class Datum {
  String? label;
  double? value;

  Datum({
    this.label,
    this.value,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        label: json["label"]?.toString(),
        value: json["value"] == null
            ? null
            : (json["value"] is num
                ? (json["value"] as num).toDouble()
                : double.tryParse(json["value"].toString())),
      );

  Map<String, dynamic> toJson() => {
    "label": label,
    "value": value,
  };
}
