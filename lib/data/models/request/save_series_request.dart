import '../../../domain/entities/content.dart';

class SaveSeriesRequest {
  List<String>? audioFormatList;
  Availability? availability;
  List<String>? castList;
  String? description;
  List<String>? directorList;
  List<String>? genreList;
  bool? isDownloadable;
  bool? isFeatured;
  List<LanguageList>? languageList;
  int? mediaHouseId;
  List<String>? posterUrlList;
  double? price;
  int? ratingCount;
  int? ratings;
  String? releaseDate;
  String? rentlDuration;
  int? runtime;
  String? sensorCertificate;
  List<String>? subtitleLanguageList;
  String? title;
  String? trailerUrl;


  SaveSeriesRequest({
    this.audioFormatList,
    this.availability,
    this.castList,
    this.description,
    this.directorList,
    this.genreList,
    this.isDownloadable,
    this.isFeatured,
    this.languageList,
    this.mediaHouseId,
    this.posterUrlList,
    this.price,
    this.ratingCount,
    this.ratings,
    this.releaseDate,
    this.rentlDuration,
    this.runtime,
    this.sensorCertificate,
    this.subtitleLanguageList,
    this.title,
    this.trailerUrl,
  });

  factory SaveSeriesRequest.fromJson(Map<String, dynamic> json) => SaveSeriesRequest(
    audioFormatList: json["audioFormatList"] == null ? [] : List<String>.from(json["audioFormatList"]!.map((x) => x)),
    availability: json["availability"] == null ? null : Availability.fromJson(json["availability"]),
    castList: json["castList"] == null ? [] : List<String>.from(json["castList"]!.map((x) => x)),
    description: json["description"],
    directorList: json["directorList"] == null ? [] : List<String>.from(json["directorList"]!.map((x) => x)),
    genreList: json["genreList"] == null ? [] : List<String>.from(json["genreList"]!.map((x) => x)),
    isDownloadable: json["isDownloadable"],
    isFeatured: json["isFeatured"],
    languageList: json["languageList"] == null ? [] : List<LanguageList>.from(json["languageList"]!.map((x) => LanguageList.fromJson(x))),
    mediaHouseId: json["mediaHouseId"],
    posterUrlList: json["posterUrlList"] == null ? [] : List<String>.from(json["posterUrlList"]!.map((x) => x)),
    price: json["price"],
    ratingCount: json["ratingCount"],
    ratings: json["ratings"],
    releaseDate: json["releaseDate"],
    rentlDuration: json["rentlDuration"],
    runtime: json["runtime"],
    sensorCertificate: json["sensorCertificate"],
    subtitleLanguageList: json["subtitleLanguageList"] == null ? [] : List<String>.from(json["subtitleLanguageList"]!.map((x) => x)),
    title: json["title"],
    trailerUrl: json["trailerURL"],
  );

  Map<String, dynamic> toJson() => {
    "audioFormatList": audioFormatList == null ? [] : List<dynamic>.from(audioFormatList!.map((x) => x)),
    "availability": availability?.toJson(),
    "castList": castList == null ? [] : List<dynamic>.from(castList!.map((x) => x)),
    "description": description,
    "directorList": directorList == null ? [] : List<dynamic>.from(directorList!.map((x) => x)),
    "genreList": genreList == null ? [] : List<dynamic>.from(genreList!.map((x) => x)),
    "isDownloadable": isDownloadable,
    "isFeatured": isFeatured,
    "languageList": languageList == null ? [] : List<dynamic>.from(languageList!.map((x) => x.toJson())),
    "mediaHouseId": mediaHouseId,
    "posterUrlList": posterUrlList == null ? [] : List<dynamic>.from(posterUrlList!.map((x) => x)),
    "price": price,
    "ratingCount": ratingCount,
    "ratings": ratings,
    "releaseDate": releaseDate,
    "rentlDuration": rentlDuration,
    "runtime": runtime,
    "sensorCertificate": sensorCertificate,
    "subtitleLanguageList": subtitleLanguageList == null ? [] : List<dynamic>.from(subtitleLanguageList!.map((x) => x)),
    "title": title,
    "trailerURL": trailerUrl,
  };
}

