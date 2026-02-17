class SeriesDetailsResponse {
  final List<SeasonBundle> seasons;
  final Series series;

  SeriesDetailsResponse({
    required this.seasons,
    required this.series,
  });

  factory SeriesDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SeriesDetailsResponse(
      seasons: ((json['seasons'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => SeasonBundle.fromJson(e))
          .toList(),
      series: Series.fromJson((json['series'] as Map<String, dynamic>?) ?? {}),
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
      season: Season.fromJson((json['season'] as Map<String, dynamic>?) ?? {}),
      episodes: ((json['episodes'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Episode.fromJson(e))
          .toList(),
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
    id: json["id"] is int ? json["id"] : int.tryParse("${json["id"]}"),
    episodeNumber: json["episodeNumber"] is int
        ? json["episodeNumber"]
        : int.tryParse("${json["episodeNumber"]}"),
    title: json["title"],
    description: json["description"],
    videoUrl: json["videoUrl"],
    posterUrl: json["posterUrl"],
    runtime:
        json["runtime"] is int ? json["runtime"] : int.tryParse("${json["runtime"]}"),
    releaseDate: json["releaseDate"] is int
        ? json["releaseDate"]
        : int.tryParse("${json["releaseDate"]}"),
    seasonId: json["seasonId"] is int
        ? json["seasonId"]
        : int.tryParse("${json["seasonId"]}"),
    amount:
        json["amount"] is int ? json["amount"] : int.tryParse("${json["amount"]}"),
    viewCount: json["viewCount"] is int
        ? json["viewCount"]
        : int.tryParse("${json["viewCount"]}"),
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
    id: json["id"] is int ? json["id"] : int.tryParse("${json["id"]}"),
    title: json["title"],
    description: json["description"],
    posterUrl: json["posterUrl"],
    seasonNumber: json["seasonNumber"] is int
        ? json["seasonNumber"]
        : int.tryParse("${json["seasonNumber"]}"),
    amount:
        json["amount"] is int ? json["amount"] : int.tryParse("${json["amount"]}"),
    releaseDate: json["releaseDate"] is int
        ? json["releaseDate"]
        : int.tryParse("${json["releaseDate"]}"),
    viewCount: json["viewCount"] is int
        ? json["viewCount"]
        : int.tryParse("${json["viewCount"]}"),
    contentId: json["contentId"] is int
        ? json["contentId"]
        : int.tryParse("${json["contentId"]}"),
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
    final rawRatings = json['ratings'];
    final rawRatingCount = json['ratingCount'];
    final rawPrice = json['price'];
    final rawTrailer = json['trailerURL'] ?? json['trailerUrl'];

    return Series(
      id: json['id'] is int ? json['id'] : int.tryParse("${json['id']}") ?? 0,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ratings: rawRatings is num
          ? rawRatings.toDouble()
          : double.tryParse("$rawRatings") ?? 0.0,
      ratingCount: rawRatingCount is int
          ? rawRatingCount
          : int.tryParse("$rawRatingCount") ?? 0,
      price: rawPrice is num ? rawPrice : num.tryParse("$rawPrice") ?? 0,
      genreList: List<String>.from((json['genreList'] ?? const []).map((x) => "$x")),
      directorList:
          List<String>.from((json['directorList'] ?? const []).map((x) => "$x")),
      castList: List<String>.from((json['castList'] ?? const []).map((x) => "$x")),
      posterUrlList:
          List<String>.from((json['posterUrlList'] ?? const []).map((x) => "$x")),
      trailerURL: (rawTrailer ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      ageRating: json['ageRating'],
    );
  }
}
