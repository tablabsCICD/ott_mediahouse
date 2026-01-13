import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/DisplayTrailer.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/component/AutoScrollingPosters.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/component/actionButtonWidget.dart';
import 'package:media_house/app/widget/StarRatingWidget.dart';
import 'package:media_house/data/repositories/pendingContent.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';

import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PendingMovieDetailsPage extends StatelessWidget {
  final int movieId;
  const PendingMovieDetailsPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    final movie = pendingContent['movies']?.firstWhere(
      (movie) => (movie['id'] == movieId),
    );

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Movie Details'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text('Movie not found.'),
        ),
      );
    }
    final controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(movie['trailer_url']) ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: true,
      ),
    );

    return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: ResponsiveWidget.isDesktop(context)
              ? Text('')
              : Text(
                  movie['title'] ?? 'Movie Details',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
        body: ResponsiveWidget.isDesktop(context)
            ? ///////////////////////////////////////////////// desktop view
            Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackground(movie['poster_url'][1]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 6,
                                        bottom: 6,
                                      ),
                                      child: Text(
                                        movie['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: selectedThemeData.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StarRatingWidget(
                                    rating: movie['rating'] ?? '0.0',
                                    starSize: 20,
                                    textSize: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${movie['rating_count'] ?? '0'} reviews)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Spacer(),
                                  _ageRating(movie['age_rating']),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: 300,
                                      child: AutoScrollingPosters(
                                        imageUrls: [
                                          movie['poster_url'][0],
                                          movie['poster_url'][1],
                                          movie['poster_url'][2],
                                        ],
                                        height: 200,
                                        aspectRatio: 2 / 3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                movie['description'] ?? 'N/A',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildButtons(context, movie),
                              const SizedBox(height: 16),
                              const SizedBox(height: 16),
                              _buildDetailsSection(context, movie),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        flex: 3,
                        child: controller.initialVideoId.isEmpty
                            ? Center(
                                child: Text(
                                  'Trailer not available',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: YoutubePlayer(
                                      controller: controller,
                                      showVideoProgressIndicator: true,
                                      progressColors: ProgressBarColors(
                                        playedColor: Colors.red,
                                        handleColor: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ) ///////////////////////////////////////////////// mobile n tab view
            : Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackground(movie['poster_url'][0]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StarRatingWidget(
                              rating: movie['rating'] ?? '0.0',
                              starSize: 20,
                              textSize: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${movie['rating_count'] ?? '0'} reviews)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Spacer(),
                            _ageRating(movie['age_rating']),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: 300,
                                child: AutoScrollingPosters(
                                  imageUrls: [
                                    movie['poster_url'][0],
                                    movie['poster_url'][1],
                                    movie['poster_url'][2],
                                  ],
                                  height: 200,
                                  aspectRatio: 2 / 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          movie['description'] ?? 'N/A',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildButtons(context, movie),
                        const SizedBox(height: 16),
                        _buildDetailsSection(context, movie),
                      ],
                    ),
                  ),
                ],
              ));
  }

  Widget _buildBackground(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey),
          )
        : Container(color: Colors.black);
  }

  Widget _ageRating(String? age_rating) {
    return age_rating != null && age_rating.isNotEmpty
        ? Tooltip(
            preferBelow: false,
            showDuration: Duration(seconds: 2),
            waitDuration: Duration(milliseconds: 500),
            message: age_rating == 'U'
                ? 'Universal Age'
                : age_rating == 'U/A'
                    ? 'Parental Guidance'
                    : 'Adults Only',
            child: Image.asset(
              height: 40,
              width: 60,
              age_rating == 'U'
                  ? ImageConstant.ageUniversal
                  : age_rating == 'U/A'
                      ? ImageConstant.ageParentalGuidance
                      : ImageConstant.ageAdultsOnly,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey),
            ),
          )
        : Container(color: Colors.black);
  }

  Widget _buildButtons(BuildContext context, Map<String, dynamic> movie) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResponsiveWidget.isDesktop(context)
            ? SizedBox()
            : ActionButtonWidget(
                label: 'Watch Trailer',
                icon: Icons.play_circle_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TrailerPage(trailerUrl: movie['trailer_url'] ?? ''),
                    ),
                  );
                },
              ),
        const SizedBox(width: 20),
        movie['status'] == "approved"
            ? ActionButtonWidget(
                label: 'Post',
                icon: Icons.local_movies,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _buildConfirmationBox(context, movie);
                    },
                  );
                },
              )
            : ActionButtonWidget(
                label: 'Edit',
                icon: Icons.movie_edit,
                onTap: () {
                  // edit content and repost
                },
              ),
        const SizedBox(width: 20),
        ActionButtonWidget(
          label: 'Rent ₹${movie['price']}',
          icon: Icons.shopping_cart,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _buildConfirmationBox(context, movie);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfirmationBox(
      BuildContext context, Map<String, dynamic> movie) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return AlertDialog(
      backgroundColor: selectedThemeData.cardColor,
      title: Center(child: Text(" Do you want to Post ${movie['title']} ?")),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedThemeData.cardColor,
            foregroundColor: selectedThemeData.canvasColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedThemeData.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.of(context).pop();

            // here make isfeatured = true to post movie
          },
          child: Text("Continue"),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(
      BuildContext context, Map<String, dynamic> movie) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        movie['status'] == 'rejected'
            ? Text(
                "Reason To Reject: ${movie['reason']},",
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
            : SizedBox(),
        _buildDetailItem('Director', movie['director'] ?? 'N/A'),
        _buildDetailItem('Cast', (movie['cast'] ?? []).join(', ')),
        _buildDetailItem('Genres', (movie['genres'] ?? []).join(', ')),
        _buildDetailItem('Runtime', movie['runtime'] ?? 'N/A'),
        _buildDetailItem('Release Date', movie['release_date'] ?? 'N/A'),
        _buildDetailItem('Languages', (movie['language'] ?? "N/A")),
        _buildDetailItem('Rating', '${movie['rating'] ?? 'N/A'} ⭐'),
        _buildDetailItem(
            'Audio Formats', (movie['audio_formats'] ?? []).join(', ')),
        _buildDetailItem('Subtitle', (movie['subtitle_language'] ?? "N/A")),
        _buildDetailItem('Age Rating', movie['age_rating'] ?? 'N/A'),
        //is_downloadable
      ],
    );
  }

  Widget _buildDetailItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$title:  $content',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
