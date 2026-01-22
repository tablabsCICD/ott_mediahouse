import 'package:flutter/material.dart';
import 'package:media_house/data/models/response/series_detail_response.dart';
import 'package:provider/provider.dart';

import '../../../../provider/themeProvider.dart';
import '../../../../provider/series_provider.dart';
import '../../movie details page/component/actionButtonWidget.dart';
import 'create_episode.dart';


class SeasonDetailPage extends StatelessWidget {
  final int seriesId;
  final SeasonBundle seasonBundle; // your Season model

  const SeasonDetailPage({
    super.key,
    required this.seriesId,
    required this.seasonBundle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(seasonBundle.season.title),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _seasonHeader(context, theme),
            const SizedBox(height: 20),
            _episodeHeader(context),
            const SizedBox(height: 10),
            Expanded(child: _episodeList(theme)),
          ],
        ),
      ),
    );
  }

  Widget _seasonHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: seasonBundle.season.posterUrl != null &&
              seasonBundle.season.posterUrl!.isNotEmpty
              ? Image.network(
            seasonBundle.season.posterUrl!,
            height: 110,
            width: 160,
            fit: BoxFit.cover,
          )
              : Container(
            height: 110,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image_not_supported, size: 40),
          ),

        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seasonBundle.season.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                seasonBundle.season.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.canvasColor),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ActionButtonWidget(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () => _editSeason(context),
                  ),
                  const SizedBox(width: 12),
                  ActionButtonWidget(
                    label: "Delete",
                    icon: Icons.delete,
                    onTap: () => _deleteSeason(context),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _episodeHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Episodes",
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

  Widget _episodeList(ThemeData theme) {
    final episodes = seasonBundle.episodes;

    if (episodes.isEmpty) {
      return const Center(
        child: Text("No episodes added yet"),
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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                  child: const Icon(Icons.image_not_supported),
                ),

              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "E${ep.episodeNumber} • ${ep.title}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ep.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEpisode(context, ep.id),
              ),
            ],
          ),
        );
      },
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

            /*  await Provider.of<SeriesProvider>(context, listen: false)
                  .deleteSeason(seriesId, season.season.id);
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
  /*  await Provider.of<SeriesProvider>(context, listen: false)
        .deleteEpisode(seriesId, season.season.id, episodeId);
*/
    Provider.of<SeriesProvider>(context, listen: false)
        .loadSeries(seriesId);
  }
}
