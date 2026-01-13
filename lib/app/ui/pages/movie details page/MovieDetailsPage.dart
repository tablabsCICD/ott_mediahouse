import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/app/ui/pages/DisplayTrailer.dart';
import 'package:media_house/app/ui/pages/editMovie.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/component/AutoScrollingPosters.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/component/MovieSalesTable.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/component/actionButtonWidget.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/component/movieRevenueGraph.dart';
import 'package:media_house/app/widget/CustomLineGraph.dart';
import 'package:media_house/app/widget/StarRatingWidget.dart';
import 'package:media_house/data/repositories/demo.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../domain/entities/content.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  bool isTrailer = true;
  bool isfullscreen = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }
  Future<void> _fetchData() async {
    await Provider.of<VideoProvider>(context, listen: false).getContentById(widget.movieId);
    await Provider.of<VideoProvider>(context, listen: false).contentRevenueGraph(1,widget.movieId,'','');
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;




    void deleteMovie(Content content) {
      Provider.of<VideoProvider>(context, listen: false).deleteVideo(content.id!,context);
      Navigator.pop(context);
    }

    return  isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Consumer<VideoProvider>(
        builder: (context, provider, child) {
          final movie = provider.content;

          if (movie == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
          backgroundColor: selectedThemeData.scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: ResponsiveWidget.isDesktop(context)
                ? Text('')
                : Text(
                    movie.title ?? 'Movie Details',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
            actions: [
              ResponsiveWidget.isMobile(context)
                  ? IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: selectedThemeData.cardColor,
                              child: MovieRevenueGraph(
                                title: 'MovieDetailsGraph',
                                yAxisLabel: 'sales',
                                graphNumber: 0,
                                contentId: movie.id!,
                                metrics: ["revenue"],
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.bar_chart_sharp,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        tooltip: 'Delete Content',
                        onPressed: () {
                          // Show the AlertDialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: selectedThemeData.cardColor,
                                title: Text(
                                    'Do you want to delete ${movie.title}?'),
                                actions: [
                                  TextButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          selectedThemeData.cardColor,
                                      foregroundColor:
                                          selectedThemeData.canvasColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          selectedThemeData.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      deleteMovie(movie);
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
          body: ResponsiveWidget.isDesktop(context)
              ? ///////////////////////////////////////////////// desktop view
              Stack(
                  fit: StackFit.expand,
                  children: [
                    if(movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)_buildBackground(movie.posterUrlList![0]),
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
                    isfullscreen
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        color: selectedThemeData.cardColor
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedThemeData.canvasColor
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Total Revenue',
                                            style: TextStyle(
                                              color:
                                                  selectedThemeData.primaryColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            movie.totalRevenue.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 100,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        color: selectedThemeData.cardColor
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedThemeData.canvasColor
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Total Tickets Sold',
                                            style: TextStyle(
                                              color:
                                                  selectedThemeData.primaryColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '0',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 100,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        color: selectedThemeData.cardColor
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedThemeData.canvasColor
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Total Views',
                                            style: TextStyle(
                                              color:
                                                  selectedThemeData.primaryColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            movie.views.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isfullscreen = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.fullscreen_exit_sharp,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 500,
                                          child: MovieRevenueGraph(
                                            title: 'MovieDetailsGraph',
                                            yAxisLabel: 'sales',
                                            graphNumber: 0,
                                            contentId: movie.id!,
                                            metrics: ["revenue"],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Divider(
                                    color:
                                        selectedThemeData.canvasColor.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 700,
                                  //width: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: MovieSalesTable(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            ///////////// isfullscreen == false
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color:
                                                    Colors.white.withOpacity(0.5),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 6,
                                                bottom: 6,
                                              ),
                                              child: Text(
                                                movie.title??"",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  color: selectedThemeData
                                                      .primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          StarRatingWidget(
                                            rating: movie.ratings!,
                                            starSize: 20,
                                            textSize: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${movie.ratingCount ?? '0'} reviews)',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Spacer(),
                                          _ageRating(movie.ageRating??""),
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
                                                  if (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
                                                    movie.posterUrlList!.length > 0 ? movie.posterUrlList![0] : "",
                                                  if (movie.posterUrlList!.length > 1)
                                                    movie.posterUrlList![1],
                                                  if (movie.posterUrlList!.length > 2)
                                                    movie.posterUrlList![2],
                                                ],
                                                height: 300,
                                                aspectRatio: 2 / 3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        movie.description ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildButtons(context, movie,provider),
                                      const SizedBox(height: 16),
                                      const SizedBox(height: 16),
                                      _buildDetailsSection(context, movie,selectedThemeData),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              isTrailer
                                  ? Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 100,
                                          ),
                                          ActionButtonWidget(
                                            label: isTrailer
                                                ? "See Analytics"
                                                : "Watch Trailer",
                                            icon: isTrailer
                                                ? Icons.analytics_outlined
                                                : Icons.play_circle_fill,
                                            onTap: () {
                                              setState(() {
                                                if (isTrailer) {
                                                  isTrailer = false;
                                                } else {
                                                  isTrailer = true;
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            height: 100,
                                          ),
                                          movie.trailerUrl == null || movie.trailerUrl == ""
                                              ? Center(
                                                  child: Text(
                                                    'Trailer not available',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 18),
                                                  ),
                                                )
                                              :  Expanded(
                                              flex: 2,
                                              child: TrailerPage(trailerUrl: movie.trailerUrl??"",)
                                          ),
                                        ],
                                      ),
                                    )
                                  : Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 100,
                                          ),
                                          ActionButtonWidget(
                                            label: isTrailer
                                                ? "See Analytics"
                                                : "Watch Trailer",
                                            icon: isTrailer
                                                ? Icons.analytics_outlined
                                                : Icons.play_circle_fill,
                                            onTap: () {
                                              setState(() {
                                                if (isTrailer) {
                                                  isTrailer = false;
                                                } else {
                                                  isTrailer = true;
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            height: 70,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isfullscreen = true;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.fullscreen,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              height: 500,
                                              child: MovieRevenueGraph(
                                                title: 'MovieDetailsGraph',
                                                yAxisLabel: 'sales',
                                                graphNumber: 0,
                                                contentId: movie.id!,
                                                metrics: ["revenue"],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                  ],
                ) ///////////////////////////////////////////////// mobile n tab view
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildBackground(movie.posterUrlList![0]),
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
                                rating: movie.ratings!,
                                starSize: 20,
                                textSize: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${movie.ratingCount ?? '0'} reviews)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              Spacer(),
                              _ageRating(movie.ageRating??""),
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
                                      if (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
                                        movie.posterUrlList!.length > 0 ? movie.posterUrlList![0] : "",
                                      if (movie.posterUrlList!.length > 1)
                                        movie.posterUrlList![1],
                                      if (movie.posterUrlList!.length > 2)
                                        movie.posterUrlList![2],
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
                            movie.description ?? 'N/A',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildButtons(context, movie,provider),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          _buildDetailsSection(context, movie,selectedThemeData),
                        ],
                      ),
                    ),
                  ],
                ));}
    );
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

  Widget _buildButtons(BuildContext context, Content movie, VideoProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResponsiveWidget.isDesktop(context)
            ? SizedBox()
            : ActionButtonWidget(
                label: 'Watch Trailer',
                icon: Icons.play_circle_fill,
                onTap: () {
                  provider.setValu(movie);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TrailerPage(trailerUrl: movie.trailerUrl ?? ''),
                    ),
                  );
                },
              ),
        const SizedBox(width: 20),
        ActionButtonWidget(
          label: 'Watch Movie',
          icon: Icons.play_circle_fill,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TrailerPage(trailerUrl: movie.contentUrl ?? ''),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        ActionButtonWidget(
          label: 'Edit Movie',
          icon: Icons.edit,
          onTap: () {
            provider.setValu(movie);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditVideoMovie(movieId: movie.id!),
              ),
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
      title: Center(child: Text("${movie['title']}")),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Price: ₹${movie['price']}'),
          Text('Duration: ${movie['rental_duration']}'),
          SizedBox(
            height: 10,
          ),
          Text('Do you want to Rent this movie ?'),
        ],
      ),
      contentTextStyle: TextStyle(
          //fontSize: 14,
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
            Navigator.of(context).pop(); // Close the dialog
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
            Navigator.of(context).pop(); // Close the dialog
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => PaymentPage(
            //       movieId: movie['id'],
            //     ),
            //   ),
            // );
          },
          child: Text("Continue"),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(
      BuildContext context, Content movie,ThemeData selectedThemeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        movie.approvalStatus!.toLowerCase() == 'rejected'
            ? Text(
          "Reason For Rejection: ${movie.reason},",
          style: TextStyle(
            color: selectedThemeData.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
          textAlign: TextAlign.center,
        )
            : SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Edit Request Reason :  ${movie.reason??"N/A"}',
            style:
            TextStyle(color:selectedThemeData.primaryColor, fontWeight: FontWeight.bold,fontSize: 16),
          ),
        ),
        _buildDetailItem('Edit Request Reason:', movie.reason??"N/A"),
        _buildDetailItem('Director',   (movie.directorList != null &&
            movie.directorList!.isNotEmpty)
            ? movie.directorList!.first
            : 'Unknown'),
        _buildDetailItem('Cast',  (movie.castList != null &&
            movie.castList!.isNotEmpty)
            ? movie.castList!.join(', ')
            : 'N/A'),
        _buildDetailItem('Genres',  (movie.genreList != null &&
            movie.genreList!.isNotEmpty)
            ? movie.genreList!.join(', ')
            : 'N/A'),
        _buildDetailItem('Runtime', movie.runtime!.toString()),
        _buildDetailItem('Release Date',movie.releaseDate ?? 'N/A'),
        _buildDetailItem('Languages', (movie.languageList ?? []).join(', ')),
        _buildDetailItem('Rating', '${movie.ratings ?? 0.0} ⭐'),
        _buildDetailItem(
            'Audio Formats', (movie.audioFormatList ?? []).join(', ')),
        _buildDetailItem('Subtitle', (movie.subtitleLanguageList ?? []).join(', ')),
        _buildDetailItem('Age Rating', movie.ageRating ?? 'N/A'),
        _buildDetailItem('Platform Percentage', movie.adminIncentivePecentage.toString() ?? 'N/A'),
        _buildDetailItem('MediaHouse Percentage', movie.mediaHouseIncentivePecentage.toString() ?? 'N/A'),
        //is_downloadable
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
