class SeriesDetailsResponse {
  final List<SeasonBundle> seasons;
  final Series series;

  SeriesDetailsResponse({
    required this.seasons,
    required this.series,
  });

  factory SeriesDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SeriesDetailsResponse(
      seasons: (json['seasons'] as List)
          .map((e) => SeasonBundle.fromJson(e))
          .toList(),
      series: Series.fromJson(json['series']),
    );
  }
}

class SeasonBundle {
  final Season season;
  final List<Episode> episodes;

  SeasonBundle({
    required this.season,
    required this.episodes,
  });

  factory SeasonBundle.fromJson(Map<String, dynamic> json) {
    return SeasonBundle(
      season: Season.fromJson(json['season']),
      episodes:
      (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
    );
  }
}

class Episode {
  int? id;
  int? episodeNumber;
  String? title;
  String? description;
  String? videoUrl;
  String? posterUrl;
  int? runtime;
  int? releaseDate;
  int? seasonId;
  int? amount;
  int? viewCount;
  String? partName;
  bool? free;
  bool? active;

  Episode({
    this.id,
    this.episodeNumber,
    this.title,
    this.description,
    this.videoUrl,
    this.posterUrl,
    this.runtime,
    this.releaseDate,
    this.seasonId,
    this.amount,
    this.viewCount,
    this.partName,
    this.free,
    this.active,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    id: json["id"],
    episodeNumber: json["episodeNumber"],
    title: json["title"],
    description: json["description"],
    videoUrl: json["videoUrl"],
    posterUrl: json["posterUrl"],
    runtime: json["runtime"],
    releaseDate: json["releaseDate"],
    seasonId: json["seasonId"],
    amount: json["amount"],
    viewCount: json["viewCount"],
    partName: json["partName"],
    free: json["free"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "episodeNumber": episodeNumber,
    "title": title,
    "description": description,
    "videoUrl": videoUrl,
    "posterUrl": posterUrl,
    "runtime": runtime,
    "releaseDate": releaseDate,
    "seasonId": seasonId,
    "amount": amount,
    "viewCount": viewCount,
    "partName": partName,
    "free": free,
    "active": active,
  };
}

class Season {
  int? id;
  String? title;
  String? description;
  dynamic posterUrl;
  int? seasonNumber;
  int? amount;
  int? releaseDate;
  int? viewCount;
  int? contentId;
  bool? active;

  Season({
    this.id,
    this.title,
    this.description,
    this.posterUrl,
    this.seasonNumber,
    this.amount,
    this.releaseDate,
    this.viewCount,
    this.contentId,
    this.active,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    posterUrl: json["posterUrl"],
    seasonNumber: json["seasonNumber"],
    amount: json["amount"],
    releaseDate: json["releaseDate"],
    viewCount: json["viewCount"],
    contentId: json["contentId"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "posterUrl": posterUrl,
    "seasonNumber": seasonNumber,
    "amount": amount,
    "releaseDate": releaseDate,
    "viewCount": viewCount,
    "contentId": contentId,
    "active": active,
  };
}

class Series {
  final int id;
  final String title;
  final String description;
  final double ratings;
  final int ratingCount;
  final num price;
  final List<String> genreList;
  final List<String> directorList;
  final List<String> castList;
  final List<String> posterUrlList;
  final String trailerURL;
  final String type;
  final String? ageRating;

  Series({
    required this.id,
    required this.title,
    required this.description,
    required this.ratings,
    required this.ratingCount,
    required this.price,
    required this.genreList,
    required this.directorList,
    required this.castList,
    required this.posterUrlList,
    required this.trailerURL,
    required this.type,
    this.ageRating,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ratings: (json['ratings'] as num).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      price: json['price'],
      genreList: List<String>.from(json['genreList']),
      directorList: List<String>.from(json['directorList']),
      castList: List<String>.from(json['castList']),
      posterUrlList: List<String>.from(json['posterUrlList']),
      trailerURL: json['trailerURL'],
      type: json['type'],
      ageRating: json['ageRating'],
    );
  }
}