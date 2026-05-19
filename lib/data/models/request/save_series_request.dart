import '../../../domain/entities/content.dart';

class SaveSeriesRequest {
  List<String>? audioFormatList;
  Availability? availability;
  List<String>? castList;
  String? description;
  List<String>? directorList;
  List<String>? genreList;
  String? aggrementDocument;
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
  int? ratings;
  String? releaseDate;
  String? rentlDuration;
  int? runtime;
  int? numberOfAttempt;
  int? fullAttempt;
  String? sensorCertificate;
  List<String>? subtitleLanguageList;
  String? title;
  String? teaserUrl;
  String? trailerUrl;


  SaveSeriesRequest({
    this.audioFormatList,
    this.availability,
    this.castList,
    this.description,
    this.directorList,
    this.genreList,
    this.aggrementDocument,
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
    this.releaseDate,
    this.rentlDuration,
    this.runtime,
    this.numberOfAttempt,
    this.fullAttempt,
    this.sensorCertificate,
    this.subtitleLanguageList,
    this.title,
    this.teaserUrl,
    this.trailerUrl,
  });

  factory SaveSeriesRequest.fromJson(Map<String, dynamic> json) => SaveSeriesRequest(
    audioFormatList: json["audioFormatList"] == null ? [] : List<String>.from(json["audioFormatList"]!.map((x) => x)),
    availability: json["availability"] == null ? null : Availability.fromJson(json["availability"]),
    castList: json["castList"] == null ? [] : List<String>.from(json["castList"]!.map((x) => x)),
    description: json["description"],
    directorList: json["directorList"] == null ? [] : List<String>.from(json["directorList"]!.map((x) => x)),
    genreList: json["genreList"] == null ? [] : List<String>.from(json["genreList"]!.map((x) => x)),
    aggrementDocument: json["aggrementDocument"],
    isAggrement: json["isAggrement"],
    isDownloadable: json["isDownloadable"],
    isFeatured: json["isFeatured"],
    isPaid: json["isPaid"],
    isReadyForApproval: json["isReadyForApproval"],
    registrationFeePaid: json["registrationFeePaid"],
    registrationFeeDetails: json["registrationFeeDetails"],
    languageList: json["languageList"] == null ? [] : List<LanguageList>.from(json["languageList"]!.map((x) => LanguageList.fromJson(x))),
    mediaHouseId: json["mediaHouseId"],
    posterUrlList: json["posterUrlList"] == null ? [] : List<String>.from(json["posterUrlList"]!.map((x) => x)),
    price: json["price"],
    ratingCount: json["ratingCount"],
    ratings: json["ratings"],
    releaseDate: json["releaseDate"],
    rentlDuration: json["rentlDuration"],
    runtime: json["runtime"],
    numberOfAttempt: json["numberOfAttempt"],
    fullAttempt: json["fullAttempt"],
    sensorCertificate: json["sensorCertificate"],
    subtitleLanguageList: json["subtitleLanguageList"] == null ? [] : List<String>.from(json["subtitleLanguageList"]!.map((x) => x)),
    title: json["title"],
    teaserUrl: json["teaserUrl"],
    trailerUrl: json["trailerURL"],
  );

  Map<String, dynamic> toJson() => {
    "audioFormatList": audioFormatList == null ? [] : List<dynamic>.from(audioFormatList!.map((x) => x)),
    "availability": availability?.toJson(),
    "castList": castList == null ? [] : List<dynamic>.from(castList!.map((x) => x)),
    "description": description,
    "directorList": directorList == null ? [] : List<dynamic>.from(directorList!.map((x) => x)),
    "genreList": genreList == null ? [] : List<dynamic>.from(genreList!.map((x) => x)),
    "aggrementDocument": aggrementDocument,
    "isAggrement": isAggrement,
    "isDownloadable": isDownloadable,
    "isFeatured": isFeatured,
    "isPaid": isPaid,
    "isReadyForApproval": isReadyForApproval,
    "registrationFeePaid": registrationFeePaid,
    "registrationFeeDetails": registrationFeeDetails,
    "languageList": languageList == null ? [] : List<dynamic>.from(languageList!.map((x) => x.toJson())),
    "mediaHouseId": mediaHouseId,
    "posterUrlList": posterUrlList == null ? [] : List<dynamic>.from(posterUrlList!.map((x) => x)),
    "price": price,
    "ratingCount": ratingCount,
    "ratings": ratings,
    "releaseDate": releaseDate,
    "rentlDuration": rentlDuration,
    "runtime": runtime,
    "numberOfAttempt": numberOfAttempt,
    "fullAttempt": fullAttempt,
    "sensorCertificate": sensorCertificate,
    "subtitleLanguageList": subtitleLanguageList == null ? [] : List<dynamic>.from(subtitleLanguageList!.map((x) => x)),
    "title": title,
    "teaserUrl": teaserUrl,
    "trailerURL": trailerUrl,
  };
}

