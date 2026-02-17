import 'package:flutter/material.dart';

import '../../domain/entities/content.dart';
import '../ui/pages/movie details page/MovieDetailsPage.dart';
import '../ui/pages/sereis/components/series_details_page.dart';

class ContentWideCard extends StatelessWidget {
  final Content content;

  const ContentWideCard({
    super.key,
    required this.content,
  });

  bool get _isSeries {
    final type = (content.type ?? "").toLowerCase();
    return type.contains("series") || content.seasonId != null;
  }

  String _compact(num value) {
    if (value >= 10000000) return "${(value / 10000000).toStringAsFixed(1)}Cr";
    if (value >= 100000) return "${(value / 100000).toStringAsFixed(1)}L";
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(1)}K";
    return value.toStringAsFixed(0);
  }

  num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  String _listOrNa(List<String>? values) {
    if (values == null || values.isEmpty) return "N/A";
    return values.join(", ");
  }

  void _openDetails(BuildContext context) {
    if (_isSeries) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeriesDetailsPage(
            seriesId: content.id ?? 0,
            content: content,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailsPage(movieId: content.id ?? 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = (content.posterUrlList != null && content.posterUrlList!.isNotEmpty)
        ? content.posterUrlList!.first
        : "";

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetails(context),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.canvasColor.withValues(alpha: 0.12),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(theme),
                  )
                else
                  _placeholder(theme),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.20),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _badge(
                    label: (content.type ?? "CONTENT").toUpperCase(),
                    color: theme.primaryColor,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _badge(
                    label: content.approvalStatus ?? "UNKNOWN",
                    color: _statusColor(content.approvalStatus),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title ?? "Untitled",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Director: ${_listOrNa(content.directorList)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Cast: ${_listOrNa(content.castList)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _metric(Icons.star_rate_rounded,
                              "${(content.ratings ?? 0).toStringAsFixed(1)}"),
                          _metric(Icons.thumb_up_alt_outlined,
                              _compact(_toNum(content.ratingCount))),
                          _metric(Icons.visibility_outlined,
                              _compact(_toNum(content.views))),
                          _metric(Icons.currency_rupee_rounded,
                              _compact(_toNum(content.totalRevenue))),
                          _metric(Icons.calendar_today_outlined,
                              "${content.releaseDate ?? 'N/A'}"),
                          _metric(
                            _isSeries ? Icons.video_library_outlined : Icons.timer_outlined,
                            _isSeries
                                ? "Series"
                                : "${content.runtime ?? 0} min",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: theme.cardColor,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        size: 44,
        color: theme.canvasColor.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            value,
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

  Color _statusColor(String? status) {
    switch ((status ?? "").toLowerCase()) {
      case "approved":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}

