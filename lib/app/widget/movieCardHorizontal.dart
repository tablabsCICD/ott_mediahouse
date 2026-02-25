import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/pendingMovieDetailsPage.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/content.dart';
import '../ui/pages/movie details page/MovieDetailsPage.dart';
import '../ui/pages/movie details page/component/setPercentageDialog.dart';
import '../ui/pages/sereis/components/series_details_page.dart';

class MovieCardHorizontal extends StatelessWidget {
  final Content movie;

  const MovieCardHorizontal({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final theme = themeProvider.getTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        movie.type == "MOVIE"
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsPage(movieId: movie.id!),
                ),
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeriesDetailsPage(
                    seriesId: movie.id!,
                    content: movie,
                  ),
                ),
              );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.all(12),
        // height: 175, // 👈 HARD FIX HEIGHT
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 0.6),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _poster(),
                  const SizedBox(width: 14),
                  Expanded(child: _details(context, theme)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _ratingBar(),
            const SizedBox(height: 6),
            _metaRow(),
          ],
        ),
      ),
    );
  }

  Widget _poster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 110,
        height: 155,
        child: movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty
            ? Image.network(
                movie.posterUrlList!.first,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _errorPoster();
                },
              )
            : _errorPoster(),
      ),
    );
  }

  Widget _errorPoster() {
    return Container(
      width: 110,
      height: 155,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.movie, size: 45, color: Colors.black54),
    );
  }

  Widget _details(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                movie.title ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _contentTypeBadge(theme),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          // 👈 THIS IS THE MAGIC FIX
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _keyValue("Director", _join(movie.directorList)),
              _keyValue("Cast", _join(movie.castList)),
              _keyValue("Price", movie.price?.toString() ?? "N/A"),
              _keyValue(
                  "Total Revenue", movie.totalRevenue?.toString() ?? "N/A"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contentTypeBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: movie.type == "MOVIE" ? theme.primaryColor : theme.primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        movie.type ?? "",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: movie.type == "MOVIE" ? Colors.white : Colors.white,
        ),
      ),
    );
  }

  Widget _ratingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ratingChip(),
        const SizedBox(width: 8),
        _likesChip(),
        const SizedBox(width: 8),
        _statusChip(),
      ],
    );
  }

  Widget _ratingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 15, color: Colors.amber),
          const SizedBox(width: 4),
          Text("${movie.ratings ?? 0}"),
        ],
      ),
    );
  }

  Widget _likesChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.pink),
          const SizedBox(width: 4),
          Text(
            "${movie.ratingCount ?? 0}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    final isApproved = movie.approvalStatus?.toLowerCase() == "approved";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved
            ? Colors.green.withOpacity(.12)
            : Colors.orange.withOpacity(.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isApproved ? Icons.verified : Icons.pending,
            size: 14,
            color: isApproved ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            movie.approvalStatus ?? "Pending",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isApproved ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaItem(
          movie.type == "SERIES" ? Icons.video_library_outlined : Icons.timer,
          movie.type == "SERIES"
              ? "${_seriesEpisodes()} Episodes"
              : "${movie.runtime ?? 0} min",
        ),
        const SizedBox(width: 14),
        _metaItem(Icons.date_range, movie.releaseDate ?? "N/A"),
        const SizedBox(width: 14),
        _metaItem(Icons.visibility, "${movie.views ?? 0} Views"),
      ],
    );
  }

  int _seriesEpisodes() {
    final dynamic value = movie.episodeId;
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _keyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          children: [
            TextSpan(
              text: "$key: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _join(List<String>? list) {
    if (list == null || list.isEmpty) return "N/A";
    return list.join(', ');
  }

  showSetPercentageDialog(BuildContext context, Content content) async {
    final double? result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return SetPercentageDialog(content: content);
      },
    );

    if (result != null) {
      debugPrint("Selected Percentage: ${result.toInt()}%");
      CustomToast.show(
        'Selected Percentage : ${result.toInt()}%',
        isSuccess: false,
      );
    }
  }
}
