import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/DisplayTrailer.dart';
import 'package:media_house/app/ui/pages/sereis/components/season_details.dart';
import 'package:media_house/data/models/response/series_detail_response.dart';
import 'package:media_house/domain/entities/content.dart';
import 'package:provider/provider.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../provider/series_provider.dart';
import '../../../../provider/themeProvider.dart';
import '../../../../provider/videoProvider.dart';
import '../../editMovie.dart';
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
  int _posterIndex = 0;
  bool _showFullDescription = false;
  final PageController _posterController = PageController();

  @override
  void initState() {
    super.initState();
    Provider.of<SeriesProvider>(context, listen: false)
        .loadSeries(widget.seriesId);
  }

  @override
  void dispose() {
    _posterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: _loadingSkeleton(theme),
          );
        }

        final data = provider.data;
        if (data == null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Text(
                provider.error ?? "No data",
                style: TextStyle(color: theme.canvasColor),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final series = data.series;
        final seasons = [...data.seasons]..sort(
            (a, b) => (a.season.seasonNumber ?? 0).compareTo(
              b.season.seasonNumber ?? 0,
            ),
          );
        if (seasons.isNotEmpty && selectedSeasonIndex >= seasons.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => selectedSeasonIndex = seasons.length - 1);
          });
        }
        final safeIndex = selectedSeasonIndex.clamp(
          0,
          seasons.isEmpty ? 0 : seasons.length - 1,
        );
        final currentSeason = seasons.isEmpty ? null : seasons[safeIndex];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              series.title,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.cardColor.withValues(alpha: 0.2),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 14,
                  vertical: 14,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: isDesktop
                              ? _topDesktopLayout(
                                  theme, series, seasons, currentSeason)
                              : _topMobileLayout(
                                  theme,
                                  series,
                                  seasons,
                                  currentSeason,
                                ),
                        ),
                        const SizedBox(height: 18),
                        _seasonSection(theme, seasons),
                        const SizedBox(height: 18),
                        _episodeSection(theme, currentSeason),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topDesktopLayout(
    ThemeData theme,
    Series series,
    List<SeasonBundle> seasons,
    SeasonBundle? currentSeason,
  ) {
    return _surfaceCard(
      theme,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _leftPosterPanel(theme, series),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _rightInfoPanel(theme, series),
                const SizedBox(height: 14),
                _analyticsSection(theme, series, seasons),
                if (currentSeason != null) ...[
                  const SizedBox(height: 14),
                  _surfaceCard(
                    theme,
                    child: buildSeasonAnalyticsDashboard(theme, currentSeason),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topMobileLayout(
    ThemeData theme,
    Series series,
    List<SeasonBundle> seasons,
    SeasonBundle? currentSeason,
  ) {
    return Column(
      children: [
        _leftPosterPanel(theme, series),
        const SizedBox(height: 14),
        _rightInfoPanel(theme, series),
        const SizedBox(height: 14),
        _analyticsSection(theme, series, seasons),
        if (currentSeason != null) ...[
          const SizedBox(height: 14),
          _surfaceCard(
            theme,
            child: buildSeasonAnalyticsDashboard(theme, currentSeason),
          ),
        ]
      ],
    );
  }

  Widget _leftPosterPanel(ThemeData theme, Series series) {
    final posters = series.posterUrlList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: posters.isEmpty
                ? _posterFallback(theme)
                : PageView.builder(
                    controller: _posterController,
                    itemCount: posters.length,
                    onPageChanged: (index) {
                      if (!mounted) return;
                      setState(() => _posterIndex = index);
                    },
                    itemBuilder: (_, i) {
                      return Image.network(
                        posters[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _posterFallback(theme),
                      );
                    },
                  ),
          ),
        ),
        if (posters.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(posters.length, (index) {
              final isActive = _posterIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isActive ? 18 : 6,
                decoration: BoxDecoration(
                  color: isActive ? theme.primaryColor : theme.dividerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 14),
        _dashboardButton(
          theme,
          label: "Rent Rs ${series.price}",
          icon: Icons.currency_rupee,
          backgroundColor: theme.primaryColor,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => _buildConfirmationBox(context, series),
            );
          },
        ),
        const SizedBox(height: 10),
        _dashboardButton(
          theme,
          label: "Watch Trailer",
          icon: Icons.play_circle_fill,
          backgroundColor: const Color(0xFF0F4C81),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrailerPage(trailerUrl: series.trailerURL),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _dashboardButton(
          theme,
          label: "Edit Series",
          icon: Icons.edit,
          backgroundColor: const Color(0xFF155EEF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditVideoMovie(movie: widget.content),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _dashboardButton(
          theme,
          label: "Delete Series",
          icon: Icons.delete_outline,
          backgroundColor: const Color(0xFFB42318),
          onTap: () => _confirmDelete(widget.content),
        ),
      ],
    );
  }

  Widget _rightInfoPanel(ThemeData theme, Series series) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          series.title,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Directors: ${_joinOrNA(series.directorList)}",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _sectionLabel(theme, "Cast"),
        const SizedBox(height: 8),
        _castRow(theme, series.castList),
        const SizedBox(height: 12),
        _sectionLabel(theme, "Genres"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: series.genreList.isEmpty
              ? [_genreChip(theme, "NA")]
              : series.genreList.map((g) => _genreChip(theme, g)).toList(),
        ),
        const SizedBox(height: 12),
        _sectionLabel(theme, "Description"),
        const SizedBox(height: 8),
        Text(
          series.description,
          maxLines: _showFullDescription ? null : 4,
          overflow: _showFullDescription
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.85),
            height: 1.45,
          ),
        ),
        if (series.description.length > 150)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                setState(() => _showFullDescription = !_showFullDescription);
              },
              child: Text(_showFullDescription ? "Show less" : "Read more"),
            ),
          ),
      ],
    );
  }

  Widget _analyticsSection(
    ThemeData theme,
    Series series,
    List<SeasonBundle> seasons,
  ) {
    final allEpisodes = seasons.expand((s) => s.episodes).toList();
    final totalEpisodes = allEpisodes.length;
    final totalViews = allEpisodes.fold<int>(
      0,
      (sum, e) => sum + (e.viewCount ?? 0),
    );
    final totalLikes = widget.content.ratingCount ?? 0;
    final totalRevenue = widget.content.totalRevenue ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 620
                ? 3
                : 2;

        final cards = [
          _analyticsCard(
              theme, Icons.currency_rupee, "Total Revenue", "$totalRevenue"),
          _analyticsCard(theme, Icons.remove_red_eye_outlined, "Total Views",
              "$totalViews"),
          _analyticsCard(
              theme, Icons.favorite_border, "Total Likes", "$totalLikes"),
          _analyticsCard(theme, Icons.movie_creation_outlined, "Total Episodes",
              "$totalEpisodes"),
          _analyticsCard(
              theme, Icons.sell_outlined, "Price / Rent", "Rs ${series.price}"),
        ];
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((card) => SizedBox(
                    width: (constraints.maxWidth - (12 * (cross - 1))) / cross,
                    child: card,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _analyticsCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return _surfaceCard(
      theme,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seasonSection(ThemeData theme, List<SeasonBundle> seasons) {
    return _surfaceCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(theme, "Seasons"),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;

              final button = ActionButtonWidget(
                label: "Add Season",
                icon: Icons.add,
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
              );

              final title = Text(
                "Manage seasons",
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 8),
                    button,
                  ],
                );
              }

              return Row(
                children: [
                  title,
                  const Spacer(),
                  SizedBox(height: 34, child: button),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          if (seasons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "No seasons available",
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            )
          else
            _seasonCardList(theme, seasons),
        ],
      ),
    );
  }

  Widget _seasonCardList(ThemeData theme, List<SeasonBundle> seasons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        /// 📱 Mobile
        if (constraints.maxWidth < 560) {
          return Column(
            children: List.generate(seasons.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == seasons.length - 1 ? 0 : 8,
                ),
                child: _seasonCard(theme, seasons[index], index),
              );
            }),
          );
        }

        /// 💻 Tablet (compact horizontal)
        if (constraints.maxWidth <= 960) {
          return SizedBox(
            height: 110, // 🔥 reduced from 150
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seasons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) => SizedBox(
                width: 200,
                child: _seasonCard(theme, seasons[index], index),
              ),
            ),
          );
        }

        /// 🖥 Desktop grid (tight)
        final columns = (constraints.maxWidth / 260).floor().clamp(1, 4);
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * 10)) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(seasons.length, (index) {
            return SizedBox(
              width: cardWidth,
              child: _seasonCard(theme, seasons[index], index),
            );
          }),
        );
      },
    );
  }

  Widget _seasonCard(ThemeData theme, SeasonBundle bundle, int index) {
    final selected = index == selectedSeasonIndex;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => selectedSeasonIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(minHeight: 90),
          decoration: BoxDecoration(
            color: selected
                ? theme.primaryColor.withValues(alpha: 0.1)
                : theme.cardColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.primaryColor.withValues(alpha: 0.4)
                  : theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              /// LEFT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "S${bundle.season.seasonNumber ?? '-'}",
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${bundle.episodes.length} eps",
                      style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              /// RIGHT BUTTON (compact)
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeasonDetailPage(
                          seriesId: widget.seriesId,
                          seasonBundle: bundle,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "View",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _episodeSection(ThemeData theme, SeasonBundle? selectedSeason) {
    return _surfaceCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(theme, "Episode List"),
          const SizedBox(height: 12),
          if (selectedSeason == null)
            Text(
              "No season selected",
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.7),
              ),
            )
          else
            _seasonEpisodesGroup(theme, selectedSeason),
        ],
      ),
    );
  }

  Widget _seasonEpisodesGroup(ThemeData theme, SeasonBundle seasonBundle) {
    final episodes = [...seasonBundle.episodes]..sort(
        (a, b) => (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0),
      );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Season ${seasonBundle.season.seasonNumber ?? '-'}",
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (episodes.isEmpty)
            Text(
              "No episodes",
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.65),
              ),
            )
          else
            ...episodes.map((ep) => _episodeCard(theme, ep)),
        ],
      ),
    );
  }

  Widget _episodeCard(ThemeData theme, Episode ep) {
    final isPublished = ep.active == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final content = compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _episodePoster(theme, ep),
                      const SizedBox(width: 12),
                      Expanded(child: _episodeInfo(theme, ep, isPublished)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _episodeActions(theme, ep),
                  ),
                ],
              )
            : Row(
                children: [
                  _episodePoster(theme, ep),
                  const SizedBox(width: 12),
                  Expanded(child: _episodeInfo(theme, ep, isPublished)),
                  const SizedBox(width: 8),
                  _episodeActions(theme, ep),
                ],
              );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: content,
        );
      },
    );
  }

  Widget buildSeasonAnalyticsDashboard(ThemeData theme, SeasonBundle season) {
    final cards = [
      _seasonSmallCard(theme, "Revenue", "Rs 0"),
      _seasonSmallCard(
        theme,
        "Views",
        "${season.episodes.fold<int>(0, (s, e) => s + (e.viewCount ?? 0))}",
      ),
      _seasonSmallCard(theme, "Episodes", "${season.episodes.length}"),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 540;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selected Season Highlights",
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (isCompact)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cards
                    .map((card) => SizedBox(
                          width: (constraints.maxWidth - 8) / 2,
                          child: card,
                        ))
                    .toList(),
              )
            else
              Row(
                children: cards
                    .map((card) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: card,
                          ),
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _seasonSmallCard(ThemeData theme, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _episodePoster(ThemeData theme, Episode ep) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 110,
        height: 68,
        child: Image.network(
          ep.posterUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
            child: const Icon(Icons.image_not_supported_outlined),
          ),
        ),
      ),
    );
  }

  Widget _episodeInfo(ThemeData theme, Episode ep, bool isPublished) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _episodeDisplayTitle(ep),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _metaChip(theme, Icons.timer, "${ep.runtime ?? 0} min"),
            _metaChip(theme, Icons.visibility, "${ep.viewCount ?? 0} views"),
            _metaChip(
              theme,
              Icons.circle,
              isPublished ? "Published" : "Draft",
            ),
          ],
        ),
      ],
    );
  }

  Widget _episodeActions(ThemeData theme, Episode ep) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        IconButton(
          tooltip: "Edit Episode",
          icon: Icon(Icons.edit_outlined, color: theme.canvasColor),
          onPressed: () {},
        ),
        IconButton(
          tooltip: "Delete Episode",
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {},
        ),
        IconButton(
          tooltip: "View Episode",
          icon: Icon(Icons.visibility_outlined, color: theme.primaryColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrailerPage(trailerUrl: ep.videoUrl ?? ''),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _castRow(ThemeData theme, List<String> cast) {
    if (cast.isEmpty) {
      return Text(
        "NA",
        style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.75)),
      );
    }

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final name = cast[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 24,
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
              SizedBox(
                width: 60,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _genreChip(ThemeData theme, String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        genre,
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _dashboardButton(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return _HoverButton(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              backgroundColor.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _metaChip(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.canvasColor.withValues(alpha: 0.72)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _surfaceCard(
    ThemeData theme, {
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _posterFallback(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_creation_outlined,
        color: theme.canvasColor.withValues(alpha: 0.6),
        size: 44,
      ),
    );
  }

  Widget _loadingSkeleton(ThemeData theme) {
    return Center(
      child: SizedBox(
        width: 1200,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _skeletonBlock(theme, height: 280),
              const SizedBox(height: 14),
              _skeletonBlock(theme, height: 160),
              const SizedBox(height: 14),
              _skeletonBlock(theme, height: 220),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonBlock(ThemeData theme, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<VideoProvider>(context, listen: false)
                  .deleteVideo(movie.id!, context);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _joinOrNA(List<String> values) {
    if (values.isEmpty) return "NA";
    return values.join(', ');
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        color: theme.canvasColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  String _episodeDisplayTitle(Episode episode) {
    final number = episode.episodeNumber;
    final title = (episode.title ?? '').trim();
    if (number == null && title.isEmpty) return "Untitled Episode";
    if (number == null) return title;
    if (title.isEmpty) return "Episode $number";
    return "E$number - $title";
  }

  String _initials(String input) {
    final parts =
        input.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _avatarColor(int index) {
    const palette = [
      Color(0xFF2F80ED),
      Color(0xFF9B51E0),
      Color(0xFF27AE60),
      Color(0xFFF2994A),
      Color(0xFFEB5757),
      Color(0xFF56CCF2),
    ];
    return palette[index % palette.length];
  }

  Widget _buildConfirmationBox(BuildContext context, Series series) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Center(
        child: Text(
          series.title,
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
          Text('Price: Rs ${series.price}'),
          const SizedBox(height: 10),
          const Text('Do you want to rent this series?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverButton({required this.child, required this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final enableHover = kIsWeb;
    return MouseRegion(
      onEnter: (_) {
        if (!enableHover) return;
        setState(() => _hovering = true);
      },
      onExit: (_) {
        if (!enableHover) return;
        setState(() => _hovering = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _hovering ? 1.02 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}
