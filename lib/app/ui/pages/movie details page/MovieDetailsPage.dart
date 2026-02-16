// UI UPDATED – LOGIC 100% SAME

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../../domain/entities/content.dart';
import '../../../provider/themeProvider.dart';
import '../../../provider/videoProvider.dart';
import '../DisplayTrailer.dart';
import '../editMovie.dart';
import 'component/AutoScrollingPosters.dart';
import 'component/actionButtonWidget.dart';
import 'component/movieRevenueGraph.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

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
      setState(() => isLoading = false);
    });
  }

  Future<void> _fetchData() async {
    await Provider.of<VideoProvider>(context, listen: false)
        .getContentById(widget.movieId);
    await Provider.of<VideoProvider>(context, listen: false)
        .contentRevenueGraph(1, widget.movieId, '', '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    void deleteMovie(Content content) {
      Provider.of<VideoProvider>(context, listen: false)
          .deleteVideo(content.id!, context);
      Navigator.pop(context);
    }

    return isLoading
        ? Scaffold(
            body: Center(
                child: CircularProgressIndicator(
            color: theme.primaryColor,
          )))
        : Consumer<VideoProvider>(builder: (context, provider, child) {
            final movie = provider.content;

            if (movie == null) {
              return Center(
                  child: CircularProgressIndicator(
                color: theme.primaryColor,
              ));
            }

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: ResponsiveWidget.isDesktop(context)
                    ? const SizedBox()
                    : Text(movie.title ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                actions: [
                  ResponsiveWidget.isMobile(context)
                      ? IconButton(
                          icon: const Icon(Icons.bar_chart),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: theme.cardColor,
                                child: MovieRevenueGraph(
                                  title: 'MovieDetailsGraph',
                                  yAxisLabel: 'sales',
                                  graphNumber: 0,
                                  contentId: movie.id!,
                                  metrics: ["revenue"],
                                ),
                              ),
                            );
                          },
                        )
                      : IconButton(
                          tooltip: 'Delete Content',
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: theme.cardColor,
                                title: Text(
                                    'Do you want to delete ${movie.title}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => deleteMovie(movie),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                ],
              ),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackground(movie.posterUrlList?[0]),
                  _darkOverlay(),
                  ResponsiveWidget.isDesktop(context)
                      ? _desktopLayout(movie, provider, theme)
                      : _mobileLayout(movie, provider, theme),
                ],
              ),
            );
          });
  }

  Widget _darkOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
    );
  }

  // ================= DESKTOP UI =================

  Widget _desktopLayout(
      Content movie, VideoProvider provider, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _leftPanel(movie, provider, theme),
        ),
        Expanded(
          flex: 3,
          child: _rightPanel(movie),
        ),
      ],
    );
  }

  Widget _leftPanel(Content movie, VideoProvider provider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              movie.title ?? "",
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          _statsRow(movie),
          const SizedBox(height: 18),
          AutoScrollingPosters(
            imageUrls: movie.posterUrlList ?? [],
            height: 320,
            aspectRatio: 2 / 3,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              movie.description ?? "N/A",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const SizedBox(height: 18),
          _buildButtons(context, movie, provider),
          const SizedBox(height: 24),
          _buildDetailsSection(context, movie, theme),
        ],
      ),
    );
  }

  Widget _rightPanel(Content movie) {
    return Column(
      children: [
        const SizedBox(height: 80),
        ActionButtonWidget(
          label: isTrailer ? "See Analytics" : "Watch Trailer",
          icon: isTrailer ? Icons.analytics_outlined : Icons.play_circle_fill,
          onTap: () => setState(() => isTrailer = !isTrailer),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: isTrailer
              ? movie.trailerUrl == null || movie.trailerUrl!.isEmpty
                  ? const Center(
                      child: Text('Trailer not available',
                          style: TextStyle(color: Colors.grey)))
                  : TrailerPage(trailerUrl: movie.trailerUrl ?? "")
              : Padding(
                  padding: const EdgeInsets.all(16.0),
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
    );
  }

  Widget _statsRow(Content movie) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard("Revenue", movie.totalRevenue.toString()),
        _statCard("Price", movie.price.toString()),
        _statCard("Views", movie.views.toString()),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================= MOBILE UI =================

  Widget _mobileLayout(Content movie, VideoProvider provider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 100),
          AutoScrollingPosters(
            imageUrls: movie.posterUrlList ?? [],
            height: 220,
            aspectRatio: 2 / 3,
          ),
          const SizedBox(height: 14),
          Text(movie.description ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          _buildButtons(context, movie, provider),
          const SizedBox(height: 14),
          _buildDetailsSection(context, movie, theme),
        ],
      ),
    );
  }

  // ================= COMMON WIDGETS =================

  Widget _buildBackground(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Container(color: Colors.black);
  }

  Widget _buildButtons(
      BuildContext context, Content movie, VideoProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResponsiveWidget.isDesktop(context)
            ? const SizedBox()
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
        const SizedBox(width: 16),
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
        const SizedBox(width: 16),
        ActionButtonWidget(
          label: 'Edit Movie',
          icon: Icons.edit,
          onTap: () {
            provider.setValu(movie);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditVideoMovie(movieId: movie.id!),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailsSection(
      BuildContext context, Content movie, ThemeData selectedThemeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "Movie Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: selectedThemeData.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        movie.approvalStatus!.toLowerCase() == 'rejected'
            ? Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Reason For Rejection : ${movie.reason}",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const SizedBox(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(4),
            },
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.white24, width: 0.5),
            ),
            children: [
              _tableRow("Edit Request Reason", movie.reason ?? "N/A"),
              _tableRow(
                  "Director",
                  movie.directorList?.isNotEmpty == true
                      ? movie.directorList!.first
                      : "Unknown"),
              _tableRow(
                  "Cast",
                  movie.castList?.isNotEmpty == true
                      ? movie.castList!.join(', ')
                      : "N/A"),
              _tableRow(
                  "Genres",
                  movie.genreList?.isNotEmpty == true
                      ? movie.genreList!.join(', ')
                      : "N/A"),
              _tableRow("Runtime", movie.runtime?.toString() ?? "N/A"),
              _tableRow("Release Date", movie.releaseDate ?? "N/A"),
              _tableRow("Languages", (movie.languageList ?? []).join(', ')),
              _tableRow("Rating", "${movie.ratings ?? 0} ⭐"),
              _tableRow(
                  "Audio Formats", (movie.audioFormatList ?? []).join(', ')),
              _tableRow(
                  "Subtitles", (movie.subtitleLanguageList ?? []).join(', ')),
              _tableRow("Age Rating", movie.ageRating ?? "N/A"),
              _tableRow("Platform Percentage",
                  movie.adminIncentivePecentage.toString()),
              _tableRow("MediaHouse Percentage",
                  movie.mediaHouseIncentivePecentage.toString()),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _tableRow(String title, String value) {
    return TableRow(
      decoration: const BoxDecoration(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
