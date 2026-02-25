import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/content.dart';
import '../../../provider/themeProvider.dart';
import '../../../provider/videoProvider.dart';
import '../DisplayTrailer.dart';
import '../editMovie.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => isLoading = false);
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

    if (isLoading) {
      return Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      );
    }

    return Consumer<VideoProvider>(
      builder: (context, provider, child) {
        final movie = provider.content;

        if (movie == null) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            ),
          );
        }

        final isDesktop = MediaQuery.of(context).size.width >= 900;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              movie.title ?? "Movie Details",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: 'Delete Content',
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: theme.cardColor,
                      title: Text('Do you want to delete ${movie.title}?'),
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
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              /*  _buildBackground(movie.posterUrlList?.isNotEmpty == true
                  ? movie.posterUrlList!.first
                  : null), */
              _darkOverlay(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 12,
                    vertical: 14,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: isDesktop ? 1050 : 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _cinematicCard(
                                        movie,
                                        provider,
                                        onDelete: () => _confirmDelete(movie),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 3,
                                      child: _rightPanels(
                                        context,
                                        movie,
                                        provider,
                                        theme,
                                        onDelete: () => _confirmDelete(movie),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _cinematicCard(
                                      movie,
                                      provider,
                                      onDelete: () => _confirmDelete(movie),
                                    ),
                                    const SizedBox(height: 12),
                                    _rightPanels(
                                      context,
                                      movie,
                                      provider,
                                      theme,
                                      onDelete: () => _confirmDelete(movie),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _rightPanels(
    BuildContext context,
    Content movie,
    VideoProvider provider,
    ThemeData selectedThemeData, {
    required VoidCallback onDelete,
  }) {
    return Column(
      children: [
        _detailsCard(child: _analysisContainer(movie)),
        const SizedBox(height: 12),
        _detailsCard(
          child: _actionContainer(context, movie, provider, onDelete: onDelete),
        ),
        const SizedBox(height: 12),
        _buildDetailsSection(context, movie, selectedThemeData),
      ],
    );
  }

  Widget _analysisContainer(Content movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Analytics Snapshot",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _metricChip("Revenue", _compactNum(movie.totalRevenue)),
            _metricChip("Views", _compactNum(movie.views)),
            _metricChip("Likes", _compactNum(movie.ratingCount)),
            _metricChip(
                "Comments", _compactNum(movie.fullAttempt ?? movie.numberOfAttempt)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: MovieRevenueGraph(
            title: 'MovieDetailsGraph',
            yAxisLabel: 'sales',
            graphNumber: 0,
            contentId: movie.id!,
            metrics: const ["revenue"],
          ),
        ),
      ],
    );
  }

  Widget _actionContainer(
    BuildContext context,
    Content movie,
    VideoProvider provider, {
    required VoidCallback onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Actions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _buildButtons(context, movie, provider),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _actionPill(
            label: "Delete Movie",
            icon: Icons.delete_outline,
            color: const Color(0xFF912B2B),
            onTap: onDelete,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(Content movie) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Do you want to delete ${movie.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<VideoProvider>(context, listen: false)
                  .deleteVideo(movie.id!, context);
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _cinematicCard(Content movie, VideoProvider provider,
      {required VoidCallback onDelete}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0E1730),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mediaPreview(movie),
          InkWell(
            onTap: () => setState(() => isTrailer = !isTrailer),
            child: Container(
              height: 48,
              width: double.infinity,
              color: const Color(0xFF616161),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTrailer ? Icons.analytics_outlined : Icons.photo_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTrailer ? "See Analytics" : "Show Poster",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22 / 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              movie.title ?? "Untitled",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28 / 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _headerChip(Icons.verified_user_outlined,
                    "Status: ${_displayValue(movie.approvalStatus)}"),
                _headerChip(Icons.business_outlined,
                    "MediaHouse: ${_displayValue(movie.mediaHouseName)}"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              _metaLine(movie),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
            child: Text(
              movie.description ?? "N/A",
              style: const TextStyle(color: Colors.white, fontSize: 18 / 1.35),
            ),
          ),
          _personLine("Producer", movie.mediaHouseName),
          _personLine(
            "Director",
            movie.directorList?.isNotEmpty == true
                ? movie.directorList!.join(', ')
                : null,
          ),
          _personLine(
            "Writer",
            movie.directorList?.length != null && movie.directorList!.length > 1
                ? movie.directorList!.sublist(1).join(', ')
                : movie.reason,
          ),
          const SizedBox(height: 12),
          _censorCertificateCard(movie),
          const SizedBox(height: 10),
          _quickActionRow(movie, provider, onDelete),
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text(
              "Star Cast :",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          _castList(movie),
          const SizedBox(height: 12),
          _trailerCard(movie),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2B4B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4C6B9A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaPreview(Content movie) {
    if (!isTrailer) {
      return Container(
        color: const Color(0xFF111111),
        child: SizedBox(
          height: 190,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: MovieRevenueGraph(
              title: 'MovieDetailsGraph',
              yAxisLabel: 'sales',
              graphNumber: 0,
              contentId: movie.id!,
              metrics: const ["revenue"],
            ),
          ),
        ),
      );
    }

    if ((movie.posterUrlList ?? []).isEmpty ||
        (movie.posterUrlList!.first).trim().isEmpty) {
      return Container(
        height: 190,
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'Poster not available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            movie.posterUrlList!.first,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xCC000000)],
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _metricChip("Revenue", _compactNum(movie.totalRevenue)),
                _metricChip("Views", _compactNum(movie.views)),
                _metricChip("Likes", _compactNum(movie.ratingCount)),
                _metricChip(
                  "Comments",
                  _compactNum(movie.fullAttempt ?? movie.numberOfAttempt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trailerCard(Content movie) {
    if ((movie.trailerUrl ?? '').trim().isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF18243F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4C6B9A)),
        ),
        child: const Center(
          child: Text(
            'Trailer not available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF18243F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C6B9A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: Text(
              "Movie Trailer",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            height: 165,
            width: double.infinity,
            child: TrailerPage(trailerUrl: movie.trailerUrl ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _censorCertificateCard(Content movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A46),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7AA5E6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF14345E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.amberAccent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Censor Certificate",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _displayValue(movie.sensorCertificate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionRow(
      Content movie, VideoProvider provider, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _actionPill(
            label: "Watch Trailer",
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
          _actionPill(
            label: "Watch Movie",
            icon: Icons.movie_creation_outlined,
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
          _actionPill(
            label: "Edit",
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
          _actionPill(
            label: "Delete",
            icon: Icons.delete_outline,
            color: const Color(0xFF912B2B),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _actionPill({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF1D3E70),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personLine(String label, String? value) {
    final safe = _displayValue(value);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: Text(
        "$label : $safe",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _castList(Content movie) {
    final cast =
        (movie.castList ?? []).where((e) => e.trim().isNotEmpty).toList();
    if (cast.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Text("N/A", style: TextStyle(color: Colors.white70)),
      );
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final name = cast[index];
          return SizedBox(
            width: 70,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _avatarColor(index),
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailsCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(.30),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1B33),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x66FFFFFF)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(
      BuildContext context, Content movie, VideoProvider provider) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        ActionButtonWidget(
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
    final languageNames = (movie.languageList ?? [])
        .map((e) => e.language)
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          "Movie Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: selectedThemeData.canvasColor,
          ),
        ),
        const SizedBox(height: 12),
        (movie.approvalStatus ?? '').toLowerCase() == 'rejected'
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
              _tableRow("Content ID", _displayValue(movie.id)),
              _tableRow("Title", _displayValue(movie.title)),
              _tableRow("Content Type", _displayValue(movie.type)),
              _tableRow("Approval Status", _displayValue(movie.approvalStatus)),
              _tableRow("Active", _boolLabel(movie.active)),
              _tableRow("Featured", _boolLabel(movie.isFeatured)),
              _tableRow("Downloadable", _boolLabel(movie.isDownloadable)),
              _tableRow("Edit Request Reason", movie.reason ?? "N/A"),
              _tableRow(
                "Director",
                movie.directorList?.isNotEmpty == true
                    ? movie.directorList!.first
                    : "Unknown",
              ),
              _tableRow(
                "Cast",
                movie.castList?.isNotEmpty == true
                    ? movie.castList!.join(', ')
                    : "N/A",
              ),
              _tableRow(
                "Genres",
                movie.genreList?.isNotEmpty == true
                    ? movie.genreList!.join(', ')
                    : "N/A",
              ),
              _tableRow("Runtime", _displayValue(movie.runtime)),
              _tableRow("Release Date", _displayValue(movie.releaseDate)),
              _tableRow("Languages",
                  languageNames.isNotEmpty ? languageNames.join(', ') : "N/A"),
              _tableRow("Rating", "${movie.ratings ?? 0} *"),
              _tableRow("Rating Count", _displayValue(movie.ratingCount)),
              _tableRow(
                  "Audio Formats", (movie.audioFormatList ?? []).join(', ')),
              _tableRow(
                  "Subtitles", (movie.subtitleLanguageList ?? []).join(', ')),
              _tableRow("Age Rating", movie.ageRating ?? "N/A"),
              _tableRow(
                  "Sensor Certificate", _displayValue(movie.sensorCertificate)),
              _tableRow("Media House", _displayValue(movie.mediaHouseName)),
              _tableRow("Media House ID", _displayValue(movie.mediaHouseId)),
              _tableRow("Rental Duration", _displayValue(movie.rentlDuration)),
              _tableRow(
                  "No. of Attempts", _displayValue(movie.numberOfAttempt)),
              _tableRow("Full Attempts", _displayValue(movie.fullAttempt)),
              _tableRow("Registration Fee Paid",
                  _displayValue(movie.registrationFeePaid)),
              _tableRow("Registration Fee Details",
                  _displayValue(movie.registrationFeeDetails)),
              _tableRow(
                  "Regions",
                  (movie.availability?.regions ?? []).isNotEmpty
                      ? movie.availability!.regions!.join(', ')
                      : "N/A"),
              _tableRow(
                  "Platforms",
                  (movie.availability?.platforms ?? []).isNotEmpty
                      ? movie.availability!.platforms!.join(', ')
                      : "N/A"),
              _tableRow("Teaser Available",
                  (movie.teaserUrl ?? '').trim().isNotEmpty ? "Yes" : "No"),
              _tableRow("Trailer Available",
                  (movie.trailerUrl ?? '').trim().isNotEmpty ? "Yes" : "No"),
              _tableRow("Video Available",
                  (movie.contentUrl ?? '').trim().isNotEmpty ? "Yes" : "No"),
              _tableRow("Uploaded On", _formatEpoch(movie.uploadDateTime)),
              _tableRow("Approved On", _formatEpoch(movie.approvedDateTime)),
              _tableRow("Watched Seconds", _displayValue(movie.watchedSeconds)),
              _tableRow(
                  "Watched Percentage", _displayValue(movie.watchedPercentage)),
              _tableRow("Season ID", _displayValue(movie.seasonId)),
              _tableRow("Episode ID", _displayValue(movie.episodeId)),
              _tableRow("Platform Percentage",
                  _displayValue(movie.adminIncentivePecentage)),
              _tableRow("MediaHouse Percentage",
                  _displayValue(movie.mediaHouseIncentivePecentage)),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _tableRow(String title, String value) {
    return TableRow(
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

  String _metaLine(Content movie) {
    final genre = (movie.genreList ?? []).join(' | ');
    final rating = movie.ageRating ?? 'U/A';
    return [if (genre.isNotEmpty) genre, rating].join('  |  ');
  }

  String _displayValue(dynamic value) {
    if (value == null) return "N/A";
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return "N/A";
    return text;
  }

  String _boolLabel(dynamic value) {
    if (value == null) return "N/A";
    if (value is bool) return value ? "Yes" : "No";
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == '1' || text == 'yes') return "Yes";
    if (text == 'false' || text == '0' || text == 'no') return "No";
    return _displayValue(value);
  }

  String _formatEpoch(int? epoch) {
    if (epoch == null || epoch <= 0) return "N/A";
    final isMilliseconds = epoch > 9999999999;
    final date = DateTime.fromMillisecondsSinceEpoch(
      isMilliseconds ? epoch : epoch * 1000,
    );
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    final hh = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return "$dd-$mm-$yyyy $hh:$min";
  }

  String _compactNum(dynamic value) {
    if (value == null) return "0";
    final n = double.tryParse(value.toString()) ?? 0;
    if (n >= 1000000000) return "${(n / 1000000000).toStringAsFixed(1)}B";
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final list = parts.toList();
    if (list.isEmpty) return "NA";
    if (list.length == 1) return list.first.substring(0, 1).toUpperCase();
    return (list.first.substring(0, 1) + list.last.substring(0, 1))
        .toUpperCase();
  }

  Color _avatarColor(int index) {
    const palette = [
      Color(0xFF315C8A),
      Color(0xFF7B4B94),
      Color(0xFF5A7D3F),
      Color(0xFF8A5A31),
      Color(0xFF2F7C7B),
    ];
    return palette[index % palette.length];
  }

  Widget _darkOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.55),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Container(color: Colors.black);
  }
}
