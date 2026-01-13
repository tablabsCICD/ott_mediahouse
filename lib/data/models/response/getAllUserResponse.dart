import '../../../domain/entities/user.dart';

class GetAllUserResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  GetAllUserResponse({this.message, this.data, this.statusCode, this.success});

  GetAllUserResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    return data;
  }
}

class Data {
  List<User>? user;

  Data({this.user});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['User'] != null) {
      user = <User>[];
      json['User'].forEach((v) {
        user!.add(new User.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['User'] = this.user!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}




