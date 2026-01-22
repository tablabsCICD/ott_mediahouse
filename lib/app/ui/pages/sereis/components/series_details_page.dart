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
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Text(
                provider.error!,
                style: TextStyle(color: theme.canvasColor),
              ),
            ),
          );
        }

        final data = provider.data;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text("No data")),
          );
        }

        Series series = data.series;
        List<SeasonBundle> seasonList = data.seasons ?? [];

        final hasSeasons = seasonList.isNotEmpty;

        final currentSeason = hasSeasons
            ? seasonList[selectedSeasonIndex.clamp(0, seasonList.length - 1)]
            : null;

        final episodes = currentSeason?.episodes ?? [];

        if (selectedSeasonIndex >= seasonList.length) {
          selectedSeasonIndex = 0;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            forceMaterialTransparency: true,
            title: ResponsiveWidget.isDesktop(context)
                ? const Text('')
                : Text(
                    series.title ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
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
              Container(
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
              ),
              ResponsiveWidget.isDesktop(context)
                  ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildLeftPane(
                            context,
                            theme,
                            series,
                            seasonList,
                            currentSeason,
                            episodes,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 400,
                                  child: TrailerPage(
                                    trailerUrl: series.trailerURL ?? '',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildMobileView(
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

  Widget _buildLeftPane(
    BuildContext context,
    ThemeData theme,
    dynamic series,
    List<SeasonBundle> seasons,
    dynamic currentSeason,
    List episodes,
  ) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildMobileView(
    BuildContext context,
    ThemeData theme,
    dynamic series,
    List<SeasonBundle> seasons,
    dynamic currentSeason,
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

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    dynamic series,
    List<SeasonBundle> seasons,
    dynamic currentSeason,
    List episodes, {
    required bool showTrailerButton,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        ResponsiveWidget.isDesktop(context)
            ? Row(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        series.title ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: series.posterUrlList?.length ?? 0,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 8,
                child: Image.network(
                  series.posterUrlList![i],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (showTrailerButton)
              ActionButtonWidget(
                label: "Watch Trailer",
                icon: Icons.play_circle_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrailerPage(
                        trailerUrl: series.trailerURL ?? '',
                      ),
                    ),
                  );
                },
              ),
            ActionButtonWidget(
              label: 'rent ₹${series.price}',
              icon: Icons.movie,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => _buildConfirmationBox(context, series),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          series.description ?? '',
          maxLines: ResponsiveWidget.isMobile(context) ? 3 : 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 16),
        Align(
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
        ),
        if (seasons.isNotEmpty)
          SizedBox(
            height: 35,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seasons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isSelected = index == selectedSeasonIndex;
                return GestureDetector(
                      onTap: (){
                        setState(() => selectedSeasonIndex = index);
                        Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeasonDetailPage(seriesId: seasons[index].season.id, seasonBundle: seasons[index],),
                          ),
                        );
                      },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      "Season ${seasons[index].season.seasonNumber}",
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.canvasColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        if (currentSeason != null)
          Text(
            currentSeason.season.description ?? '',
            maxLines: ResponsiveWidget.isMobile(context) ? 3 : 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        const SizedBox(height: 12),
        currentSeason == null
            ? SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "No seasons added yet.",
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              )
            : episodes.isEmpty
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        "Episodes will be available soon.",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: episodes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final ep = episodes[index];
                        return SizedBox(
                          width: 220,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: AspectRatio(
                                  aspectRatio: 16 / 8,
                                  child: Image.network(
                                    ep.posterUrl ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "E${ep.episodeNumber} • ${ep.title}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
        const SizedBox(height: 20),
        _buildMetaTable(theme, series),
      ],
    );
  }

  Widget _buildMetaTable(ThemeData theme, dynamic series) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.white12, width: 0.5),
        ),
        children: [
          _row("Genres", series.genreList.join(', ')),
          _row("Directors", series.directorList.join(', ')),
          _row("Cast", series.castList.join(', ')),
          _row(
            "Languages",
            (widget.content.languageList ?? [])
                .map((e) => e.language)
                .join(', '),
          ),
          _row("Rating", "${series.ratings} ⭐"),
          _row("Price", "₹${series.price}"),
        ],
      ),
    );
  }

  TableRow _row(String k, String v) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          "$k:",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          v,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    ]);
  }

  Widget _buildBackground(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Container(color: Colors.black);
  }

  Widget _buildConfirmationBox(BuildContext context, dynamic series) {
    final theme = Provider.of<ThemeProvider>(context, listen: true).getTheme;

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
          Text(
            'price: ₹${series.price}',
            style: TextStyle(color: theme.secondaryHeaderColor),
          ),
          const SizedBox(height: 10),
          Text(
            'Do you want to rent this series?',
            style: TextStyle(color: theme.primaryColor),
            textAlign: TextAlign.center,
          ),
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Continue"),
        ),
      ],
    );
  }
}
