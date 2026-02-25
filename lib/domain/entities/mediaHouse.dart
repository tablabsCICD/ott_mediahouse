import 'package:media_house/domain/entities/location.dart';
import 'package:media_house/domain/entities/user.dart';

class MediaHouse {
  int? id;
  String? mediaHouseName;
  String? address;
  String? contactNumber;
  String? email;
  String? registrationCertificate;
  String? gstCertificates;
  String? adharCard;
  dynamic shopAct;
  String? panCard;
  int? createdDate;
  dynamic updatedDate;
  dynamic profileImage;
  dynamic otp;
  dynamic password;
  String? status;
  dynamic joinDate;
  dynamic logo;
  dynamic totalReveneu;
  dynamic postCount;
  dynamic discription;
  String? bankAccountNumber;
  String? bankIfscNumber;
  String? bankProof;
  String? identityProof;
  String? addressProof;
  dynamic bankName;
  dynamic accountHolderName;
  dynamic firmType;
  User? user;
  User? director;
  User? ceo;
  Location? location;
  dynamic totalViews;
  bool? active;

  MediaHouse({
    this.id,
    this.mediaHouseName,
    this.address,
    this.contactNumber,
    this.email,
    this.registrationCertificate,
    this.gstCertificates,
    this.adharCard,
    this.shopAct,
    this.panCard,
    this.createdDate,
    this.updatedDate,
    this.profileImage,
    this.otp,
    this.password,
    this.status,
    this.joinDate,
    this.logo,
    this.totalReveneu,
    this.postCount,
    this.discription,
    this.bankAccountNumber,
    this.bankIfscNumber,
    this.bankProof,
    this.identityProof,
    this.addressProof,
    this.bankName,
    this.accountHolderName,
    this.firmType,
    this.user,
    this.director,
    this.ceo,
    this.location,
    this.totalViews,
    this.active,
  });

  factory MediaHouse.fromJson(Map<String, dynamic> json) => MediaHouse(
        id: json["id"],
        mediaHouseName: json["mediaHouseName"],
        address: json["address"],
        contactNumber: json["contactNumber"],
        email: json["email"],
        registrationCertificate: json["registrationCertificate"],
        gstCertificates: json["gstCertificates"],
        adharCard: json["adharCard"],
        shopAct: json["shopAct"],
        panCard: json["panCard"],
        createdDate: json["createdDate"],
        updatedDate: json["updatedDate"],
        profileImage: json["profileImage"],
        otp: json["otp"],
        password: json["password"],
        status: json["status"],
        joinDate: json["joinDate"],
        logo: json["logo"],
        totalReveneu: json["totalReveneu"],
        postCount: json["postCount"],
        discription: json["discription"],
        bankAccountNumber: json["bankAccountNumber"],
        bankIfscNumber: json["bankIFSCNumber"],
        bankProof: json["bankProof"],
        identityProof: json["identityProof"],
        addressProof: json["addressProof"],
        bankName: json["bankName"],
        accountHolderName: json["accountHolderName"],
        firmType: json["firmType"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        director:
            json["director"] == null ? null : User.fromJson(json["director"]),
        ceo: json["ceo"] == null ? null : User.fromJson(json["ceo"]),
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        totalViews: json["totalViews"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mediaHouseName": mediaHouseName,
        "address": address,
        "contactNumber": contactNumber,
        "email": email,
        "registrationCertificate": registrationCertificate,
        "gstCertificates": gstCertificates,
        "adharCard": adharCard,
        "shopAct": shopAct,
        "panCard": panCard,
        "createdDate": createdDate,
        "updatedDate": updatedDate,
        "profileImage": profileImage,
        "otp": otp,
        "password": password,
        "status": status,
        "joinDate": joinDate,
        "logo": logo,
        "totalReveneu": totalReveneu,
        "postCount": postCount,
        "discription": discription,
        "bankAccountNumber": bankAccountNumber,
        "bankIFSCNumber": bankIfscNumber,
        "bankProof": bankProof,
        "identityProof": identityProof,
        "addressProof": addressProof,
        "bankName": bankName,
        "accountHolderName": accountHolderName,
        "firmType": firmType,
        "user": user?.toJson(),
        "director": director?.toJson(),
        "ceo": ceo?.toJson(),
        "location": location?.toJson(),
        "totalViews": totalViews,
        "active": active,
      };
}
