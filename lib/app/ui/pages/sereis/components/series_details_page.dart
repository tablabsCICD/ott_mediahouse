import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/DisplayTrailer.dart';
import 'package:media_house/app/ui/pages/sereis/components/season_details.dart';
import 'package:media_house/data/models/response/series_detail_response.dart';
import 'package:media_house/domain/entities/content.dart';
import 'package:provider/provider.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../provider/series_provider.dart';
import '../../../../provider/themeProvider.dart';
import '../../movie details page/component/actionButtonWidget.dart';
import 'create_season_page.dart';

class SeriesDetailsPage extends StatefulWidget {
  final int seriesId;
  final Content content;

  const SeriesDetailsPage({
    super.key,
    required this.seriesId,
    required this.content,
  });

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> {
  int selectedSeasonIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<SeriesProvider>(context, listen: false)
        .loadSeries(widget.seriesId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
                child: CircularProgressIndicator(
              color: theme.primaryColor,
            )),
          );
        }

        final data = provider.data;
        if (data == null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Text(
                provider.error ?? "No data",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        Series series = data.series;
        List<SeasonBundle> seasonList = data.seasons ?? [];

        final hasSeasons = seasonList.isNotEmpty;
        final currentSeason = hasSeasons
            ? seasonList[selectedSeasonIndex.clamp(0, seasonList.length - 1)]
            : null;

        final episodes = currentSeason?.episodes ?? [];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            forceMaterialTransparency: true,
            title: ResponsiveWidget.isDesktop(context)
                ? const SizedBox()
                : Text(
                    series.title ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: theme.primaryColor,
                    ),
                  ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(
                series.posterUrlList?.isNotEmpty == true
                    ? series.posterUrlList!.first
                    : null,
              ),
              _darkOverlay(),
              ResponsiveWidget.isDesktop(context)
                  ? _desktopLayout(
                      context,
                      theme,
                      series,
                      seasonList,
                      currentSeason,
                      episodes,
                    )
                  : _mobileLayout(
                      context,
                      theme,
                      series,
                      seasonList,
                      currentSeason,
                      episodes,
                    ),
            ],
          ),
        );
      },
    );
  }

  // ===================== DESKTOP UI =====================

  Widget _desktopLayout(
    BuildContext context,
    ThemeData theme,
    Series series,
    List<SeasonBundle> seasons,
    SeasonBundle? currentSeason,
    List episodes,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildBody(
              context,
              theme,
              series,
              seasons,
              currentSeason,
              episodes,
              showTrailerButton: false,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TrailerPage(
              trailerUrl: series.trailerURL ?? '',
            ),
          ),
        ),
      ],
    );
  }

  // ===================== MOBILE UI =====================

  Widget _mobileLayout(
    BuildContext context,
    ThemeData theme,
    Series series,
    List<SeasonBundle> seasons,
    SeasonBundle? currentSeason,
    List episodes,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildBody(
            context,
            theme,
            series,
            seasons,
            currentSeason,
            episodes,
            showTrailerButton: true,
          ),
        ],
      ),
    );
  }

  // ===================== MAIN BODY =====================

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    Series series,
    List<SeasonBundle> seasons,
    SeasonBundle? currentSeason,
    List episodes, {
    required bool showTrailerButton,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            series.title ?? "",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _posterSlider(series),

        const SizedBox(height: 16),

        _actionButtons(context, series, showTrailerButton),

        const SizedBox(height: 16),

        Text(series.description ?? "",
            style: const TextStyle(color: Colors.white70)),

        const SizedBox(height: 16),

        _addSeasonButton(context),

        const SizedBox(height: 16),

        if (seasons.isNotEmpty) _seasonTabs(seasons, theme),

        const SizedBox(height: 16),

        if (currentSeason != null)
          buildSeasonAnalyticsDashboard(theme, currentSeason),

        const SizedBox(height: 16),

        /*  if (currentSeason != null)
          buildSeasonApprovalUI(theme, currentSeason, context),*/

        //  const SizedBox(height: 16),

        if (currentSeason != null)
          buildEpisodeManagementTable(theme, currentSeason),
      ],
    );
  }

  // ===================== UI WIDGETS =====================

  Widget _posterSlider(Series series) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: series.posterUrlList?.length ?? 0,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            series.posterUrlList![i],
            width: 320,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _actionButtons(BuildContext context, Series series, bool showTrailer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showTrailer)
          ActionButtonWidget(
            label: "Watch Trailer",
            icon: Icons.play_circle_fill,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TrailerPage(trailerUrl: series.trailerURL ?? ''),
                ),
              );
            },
          ),
        const SizedBox(width: 16),
        ActionButtonWidget(
          label: 'Rent ₹${series.price}',
          icon: Icons.movie,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => _buildConfirmationBox(context, series),
            );
          },
        ),
      ],
    );
  }

  Widget _addSeasonButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ActionButtonWidget(
        label: "Add Season",
        icon: Icons.add_circle,
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AddSeasonDialog(
              seriesId: widget.seriesId,
              onSuccess: () {
                Provider.of<SeriesProvider>(context, listen: false)
                    .loadSeries(widget.seriesId);
              },
            ),
          );
        },
      ),
    );
  }

  // ===================== SEASON TABS =====================

  Widget _seasonTabs(List<SeasonBundle> seasons, ThemeData theme) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final season = seasons[index];
          final isSelected = index == selectedSeasonIndex;

          return InkWell(
            onTap: () {
              setState(() => selectedSeasonIndex = index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor.withOpacity(0.15)
                    : theme.cardColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Text(
                    "Season ${season.season.seasonNumber}",
                    style: TextStyle(
                      color:
                          isSelected ? theme.primaryColor : theme.canvasColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeasonDetailPage(
                            seriesId: season.season.id!,
                            seasonBundle: season,
                          ),
                        ),
                      );
                    },
                    child: const Text("View"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===================== ANALYTICS =====================

  Widget buildSeasonAnalyticsDashboard(ThemeData theme, SeasonBundle season) {
    return Row(
      children: [
        _analyticsCard("Revenue", "₹${0}"),
        _analyticsCard("Views", "${0}"),
        _analyticsCard("Episodes", "${season.episodes.length}"),
      ],
    );
  }

  Widget _analyticsCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ===================== APPROVAL =====================

  Widget buildSeasonApprovalUI(
      ThemeData theme, SeasonBundle season, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Approval Status: ${season.season.active}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle),
                label: const Text("Approve"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cancel),
                label: const Text("Reject"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ===================== EPISODE TABLE =====================

  Widget buildEpisodeManagementTable(ThemeData theme, SeasonBundle season) {
    final episodes = season.episodes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Episode Management",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: episodes.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final item = episodes.removeAt(oldIndex);
              episodes.insert(newIndex, item);
            },
            itemBuilder: (context, i) {
              final ep = episodes[i];

              return Container(
                key: ValueKey(ep.id),
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Episode Number Badge
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        ep.posterUrl ?? '',
                        width: 120,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 70,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.movie, color: Colors.white54),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// Episode Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ep.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 16,
                            children: [
                              _metaChip(Icons.timer, "${ep.runtime} min"),
                              _metaChip(
                                  Icons.visibility, "${ep.viewCount} views"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Edit Episode",
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          tooltip: "Delete Episode",
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {},
                        ),
                        ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_indicator),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
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
    );
  }

  // ===================== HELPERS =====================

  Widget _buildBackground(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Container(color: Colors.black);
  }

  Widget _darkOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.95),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationBox(BuildContext context, dynamic series) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Center(
        child: Text(
          series.title ?? '',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('price: ₹${series.price}'),
          const SizedBox(height: 10),
          const Text('Do you want to rent this series?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Continue"),
        ),
      ],
    );
  }
}
