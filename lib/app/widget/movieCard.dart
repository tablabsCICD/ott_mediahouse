import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/MovieDetailsPage.dart';
import 'package:media_house/app/ui/pages/sereis/components/series_details_page.dart';
import 'package:media_house/app/widget/StarRatingWidget.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:media_house/domain/entities/content.dart';

class MovieCard extends StatelessWidget {
  int movieId;
  String movieName;
  String poster_url;
  double rating;
  int rating_count;
  Content movie;

  MovieCard({
    super.key,
    required this.movieId,
    required this.movieName,
    required this.poster_url,
    required this.rating,
    required this.rating_count, required this.movie,
  });

  num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  String _compact(num value) {
    if (value >= 10000000) {
      return "${(value / 10000000).toStringAsFixed(1)}Cr";
    }
    if (value >= 100000) {
      return "${(value / 100000).toStringAsFixed(1)}L";
    }
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }
    return value.toStringAsFixed(0);
  }

  Widget _metricChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget.isDesktop(context)
        ? GestureDetector(
            onTap: () {
              movie.type=="MOVIE"?Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsPage(
                    movieId: movieId,
                  ),
                ),
              ):Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeriesDetailsPage(
                   seriesId: movieId, content: movie,
                  ),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Movie Poster

                    Positioned.fill(
                      child: Image.network(
                        poster_url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Movie Information
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movieName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _metricChip(
                                Icons.visibility_outlined,
                                _compact(_toNum(movie.views)),
                              ),
                              _metricChip(
                                Icons.thumb_up_alt_outlined,
                                _compact(_toNum(movie.ratingCount)),
                              ),
                              _metricChip(
                                Icons.currency_rupee,
                                _compact(_toNum(movie.totalRevenue)),
                              ),
                            ],
                          ),

                          // Text(
                          //   '${movie['rating']}',
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.white70,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRatingWidget(
                            rating: rating,
                          ),
                          Text(
                            '($rating_count)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ) ////////////////////////////////////////////////// mobile view
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsPage(
                    movieId: movieId,
                  ),
                ),
              );
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Movie Poster
                    Positioned.fill(
                      child: Image.network(
                        poster_url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Movie Information
                    Positioned(
                      bottom: 10,
                      left: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movieName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _metricChip(
                                Icons.visibility_outlined,
                                _compact(_toNum(movie.views)),
                              ),
                              _metricChip(
                                Icons.thumb_up_alt_outlined,
                                _compact(_toNum(movie.ratingCount)),
                              ),
                              _metricChip(
                                Icons.currency_rupee,
                                _compact(_toNum(movie.totalRevenue)),
                              ),
                            ],
                          ),

                          // Text(
                          //   '${movie['rating']}',
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.white70,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRatingWidget(
                            rating: rating,
                          ),
                          Text(
                            '($rating_count)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
