import 'package:flutter/material.dart';
import 'package:media_house/data/models/response/series_detail_response.dart';
import 'package:provider/provider.dart';

import '../../../../provider/themeProvider.dart';
import '../../../../provider/series_provider.dart';
import '../../movie details page/component/actionButtonWidget.dart';
import 'create_episode.dart';

class SeasonDetailPage extends StatelessWidget {
  final int seriesId;
  final SeasonBundle seasonBundle;

  const SeasonDetailPage({
    super.key,
    required this.seriesId,
    required this.seasonBundle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          seasonBundle.season.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seasonHeader(context, theme),
            const SizedBox(height: 24),
            _episodeHeader(context),
            const SizedBox(height: 12),
            Expanded(child: _episodeList(theme)),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String title, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(height: 4),
          Text(
            "$value",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  // ================= SEASON HEADER =================

  Widget _seasonHeader(BuildContext context, ThemeData theme) {
    final season = seasonBundle.season;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: season.posterUrl != null &&
                    season.posterUrl!.isNotEmpty
                    ? Image.network(
                  season.posterUrl!,
                  height: 120,
                  width: 180,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 120,
                  width: 180,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.image_not_supported,
                      size: 40),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      season.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Season Analytics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statChip(Icons.visibility, "Views", 0),
              _statChip(Icons.favorite, "Likes", 0),
              _statChip(Icons.currency_rupee, "Revenue",0),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButtonWidget(
                label: "Edit Season",
                icon: Icons.edit,
                onTap: () => _editSeason(context),
              ),
              const SizedBox(width: 12),
              ActionButtonWidget(
                label: "Delete Season",
                icon: Icons.delete,
                onTap: () => _deleteSeason(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= EPISODE HEADER =================

  Widget _episodeHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Episode Management",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ActionButtonWidget(
          label: "Add Episode",
          icon: Icons.add_circle,
          onTap: () => _addEpisode(context),
        ),
      ],
    );
  }

  // ================= EPISODE LIST =================

  Widget _episodeList(ThemeData theme) {
    final episodes = seasonBundle.episodes;

    if (episodes.isEmpty) {
      return const Center(
        child: Text("No episodes added yet",
            style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.separated(
      itemCount: episodes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ep = episodes[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              /// Episode No
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "E${ep.episodeNumber}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(width: 12),

              /// Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ep.posterUrl.isNotEmpty
                    ? Image.network(
                  ep.posterUrl,
                  height: 70,
                  width: 110,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 70,
                  width: 110,
                  color: Colors.grey.shade800,
                  child:
                  const Icon(Icons.image_not_supported),
                ),
              ),

              const SizedBox(width: 14),

              /// Info + Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ep.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        _metaChip(Icons.timer,
                            "${ep.runtime ?? 0} min"),
                        _metaChip(Icons.visibility,
                            "${0} views"),
                        _metaChip(Icons.favorite,
                            "${0} likes"),
                        _metaChip(Icons.currency_rupee,
                            "₹${0}"),
                      ],
                    ),
                  ],
                ),
              ),

              /// Actions
              Column(
                children: [
                  IconButton(
                    tooltip: "Edit Episode",
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      // TODO: Open edit episode dialog
                    },
                  ),
                  IconButton(
                    tooltip: "Delete Episode",
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red),
                    onPressed: () =>
                        _deleteEpisode(context, ep.id),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  // ---------------- Actions ----------------

  void _editSeason(BuildContext context) {
    // TODO: open edit season dialog
  }

  void _deleteSeason(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Season"),
        content: const Text("Are you sure you want to delete this season?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              /* await Provider.of<SeriesProvider>(context, listen: false)
                  .deleteSeason(seriesId, seasonBundle.season.id);
              */

              Provider.of<SeriesProvider>(context, listen: false)
                  .loadSeries(seriesId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _addEpisode(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEpisodeDialog(
        seriesId: seriesId,
        seasonId: seasonBundle.season.id,
        onSuccess: () {
          Provider.of<SeriesProvider>(context, listen: false)
              .loadSeries(seriesId);
        },
      ),
    );
  }

  void _deleteEpisode(BuildContext context, int episodeId) async {
    /* await Provider.of<SeriesProvider>(context, listen: false)
        .deleteEpisode(seriesId, seasonBundle.season.id, episodeId);
    */

    Provider.of<SeriesProvider>(context, listen: false)
        .loadSeries(seriesId);
  }
}
