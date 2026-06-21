import '../../../domain/entities/content.dart';

class SaveSeriesRequest {
  int? id;
  String? ageRating;
  String? aggrementDocument;
  String? approvalStatus;
  String? approvedDateTime;
  List<String>? audioFormatList;
  Availability? availability;
  List<String>? castList;
  String? contentUrl;
  String? description;
  List<String>? directorList;
  List<String>? genreList;
  bool? isAggrement;
  bool? isDownloadable;
  bool? isFeatured;
  bool? isPaid;
  String? isReadyForApproval;
  String? registrationFeePaid;
  String? registrationFeeDetails;
  List<LanguageList>? languageList;
  int? mediaHouseId;
  List<String>? posterUrlList;
  double? price;
  int? ratingCount;
  double? ratings;
  String? reason;
  String? releaseDate;
  String? releaseTime;
  String? rentlDuration;
  double? runtime;
  int? numberOfAttempt;
  int? fullAttempt;
  String? sensorCertificate;
  List<String>? subtitleLanguageList;
  String? title;
  double? totalRevenue;
  String? teaserUrl;
  String? trailerUrl;
  String? type;
  String? uploadDateTime;
  int? views;

  SaveSeriesRequest({
    this.id,
    this.ageRating,
    this.aggrementDocument,
    this.approvalStatus,
    this.approvedDateTime,
    this.audioFormatList,
    this.availability,
    this.castList,
    this.contentUrl,
    this.description,
    this.directorList,
    this.genreList,
    this.isAggrement,
    this.isDownloadable,
    this.isFeatured,
    this.isPaid,
    this.isReadyForApproval,
    this.registrationFeePaid,
    this.registrationFeeDetails,
    this.languageList,
    this.mediaHouseId,
    this.posterUrlList,
    this.price,
    this.ratingCount,
    this.ratings,
    this.reason,
    this.releaseDate,
    this.releaseTime,
    this.rentlDuration,
    this.runtime,
    this.numberOfAttempt,
    this.fullAttempt,
    this.sensorCertificate,
    this.subtitleLanguageList,
    this.title,
    this.totalRevenue,
    this.teaserUrl,
    this.trailerUrl,
    this.type,
    this.uploadDateTime,
    this.views,
  });

  factory SaveSeriesRequest.fromJson(Map<String, dynamic> json) =>
      SaveSeriesRequest(
        id: json["id"],
        ageRating: json["ageRating"],
        aggrementDocument: json["aggrementDocument"],
        approvalStatus: json["approvalStatus"],
        approvedDateTime: json["approvedDateTime"],
        audioFormatList: json["audioFormatList"] == null
            ? []
            : List<String>.from(json["audioFormatList"]!.map((x) => x)),
        availability: json["availability"] == null
            ? null
            : Availability.fromJson(json["availability"]),
        castList: json["castList"] == null
            ? []
            : List<String>.from(json["castList"]!.map((x) => x)),
        contentUrl: json["contentUrl"],
        description: json["description"],
        directorList: json["directorList"] == null
            ? []
            : List<String>.from(json["directorList"]!.map((x) => x)),
        genreList: json["genreList"] == null
            ? []
            : List<String>.from(json["genreList"]!.map((x) => x)),
        isAggrement: json["isAggrement"],
        isDownloadable: json["isDownloadable"],
        isFeatured: json["isFeatured"],
        isPaid: json["isPaid"],
        isReadyForApproval: json["isReadyForApproval"],
        registrationFeePaid: json["registrationFeePaid"],
        registrationFeeDetails: json["registrationFeeDetails"],
        languageList: json["languageList"] == null
            ? []
            : List<LanguageList>.from(
                json["languageList"]!.map((x) => LanguageList.fromJson(x))),
        mediaHouseId: json["mediaHouseId"],
        posterUrlList: json["posterUrlList"] == null
            ? []
            : List<String>.from(json["posterUrlList"]!.map((x) => x)),
        price: json["price"],
        ratingCount: json["ratingCount"],
        ratings: json["ratings"],
        reason: json["reason"],
        releaseDate: json["releaseDate"],
        releaseTime: json["releaseTime"],
        rentlDuration: json["rentlDuration"],
        runtime: json["runtime"] == null
            ? null
            : double.tryParse(json["runtime"].toString()),
        numberOfAttempt: json["numberOfAttempt"],
        fullAttempt: json["fullAttempt"],
        sensorCertificate: json["sensorCertificate"],
        subtitleLanguageList: json["subtitleLanguageList"] == null
            ? []
            : List<String>.from(json["subtitleLanguageList"]!.map((x) => x)),
        title: json["title"],
        totalRevenue: json["totalRevenue"] == null
            ? null
            : double.tryParse(json["totalRevenue"].toString()),
        teaserUrl: json["teaserUrl"],
        trailerUrl: json["trailerUrl"] ?? json["trailerURL"],
        type: json["type"],
        uploadDateTime: json["uploadDateTime"],
        views: json["views"],
      );

  Map<String, dynamic> toJson() => {
        "audioFormatList": audioFormatList == null
            ? []
            : List<dynamic>.from(audioFormatList!.map((x) => x)),
        "availability": availability?.toJson(),
        "castList":
            castList == null ? [] : List<dynamic>.from(castList!.map((x) => x)),
        "description": description,
        "directorList": directorList == null
            ? []
            : List<dynamic>.from(directorList!.map((x) => x)),
        "fullAttempt": fullAttempt,
        "genreList": genreList == null
            ? []
            : List<dynamic>.from(genreList!.map((x) => x)),
        "isDownloadable": isDownloadable,
        "isFeatured": isFeatured,
        "languageList": languageList == null
            ? []
            : List<dynamic>.from(languageList!.map((x) => x.toJson())),
        "mediaHouseId": mediaHouseId,
        "numberOfAttempt": numberOfAttempt,
        "posterUrlList": posterUrlList == null
            ? []
            : List<dynamic>.from(posterUrlList!.map((x) => x)),
        "price": price,
        "ratingCount": ratingCount,
        "ratings": ratings,
        "registrationFeeDetails": registrationFeeDetails,
        "registrationFeePaid": registrationFeePaid,
        "releaseDate": releaseDate,
        "releaseTime": releaseTime,
        "rentlDuration": rentlDuration,
        "runtime": runtime,
        "sensorCertificate": sensorCertificate,
        "subtitleLanguageList": subtitleLanguageList == null
            ? []
            : List<dynamic>.from(subtitleLanguageList!.map((x) => x)),
        "teaserUrl": teaserUrl,
        "title": title,
        "trailerURL": trailerUrl,
      };
}
