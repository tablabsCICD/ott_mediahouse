import 'location.dart';

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? mobileNumber;
  String? emailId;
  String? profilePhoto;
  String? password;
  String? otp;
  String? deviceId;
  String? deviceToken;
  String? deviceName;
  String? osName;
  String? registrationDate;
  String? age;
  String? dob;
  String? joinDate;
  String? gender;
  Location? location;
  String? refferCode;
  String? refferedBy;
  List<dynamic>? role;
  bool? active;
  bool? admin;
  bool? verified;

  User(
      {this.id,
        this.firstName,
        this.lastName,
        this.mobileNumber,
        this.emailId,
        this.profilePhoto,
        this.password,
        this.otp,
        this.deviceId,
        this.deviceToken,
        this.deviceName,
        this.osName,
        this.registrationDate,
        this.age,
        this.dob,
        this.joinDate,
        this.gender,
        this.location,
        this.refferCode,
        this.refferedBy,
        this.role,
        this.active,
        this.admin,
        this.verified});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName']??"";
    lastName = json['lastName']??"";
    mobileNumber = json['mobileNumber']??"";
    emailId = json['emailId']??"";
    profilePhoto = json['profilePhoto']??"";
    password = json['password']??"";
    deviceId = json['deviceId']??"";
    deviceToken = json['deviceToken']??"";
    deviceName = json['deviceName']??"";
    osName = json['osName']??"";
    registrationDate = json['registrationDate']??"";
    age = json['age']??"";
    dob = json['dob']??"";
    joinDate = json['joinDate']??"";
    gender = json['gender']??"";
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    refferCode = json['refferCode'];
    refferedBy = json['refferedBy'];
    role = json['role'];
    if (json['role'] != null) {
      role = <String>[];
      json['role'].forEach((v) {
        role!.add((v));
      });
    }
    // role = json['role'].cast<String>();
    active = json['active']??true;
    admin = json['admin']??false;
    verified = json['verified']??false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['mobileNumber'] = this.mobileNumber;
    data['emailId'] = this.emailId;
    data['profilePhoto'] = this.profilePhoto;
    data['password'] = this.password;
    data['deviceId'] = this.deviceId;
    data['deviceToken'] = this.deviceToken;
    data['deviceName'] = this.deviceName;
    data['osName'] = this.osName;
    data['registrationDate'] = this.registrationDate;
    data['age'] = this.age;
    data['dob'] = this.dob;
    data['joinDate'] = this.joinDate;
    data['gender'] = this.gender;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['refferCode'] = this.refferCode;
    if (this.refferedBy != null) {
      data['refferedBy'] = this.refferedBy;
    }
    if (this.role != null) {
      data['role'] = this.role!.map((v) => v).toList();
    }
    // data['role'] = this.role;
    data['active'] = this.active;
    data['admin'] = this.admin;
    data['verified'] = this.verified;
    return data;
  }
}
