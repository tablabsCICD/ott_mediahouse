import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_house/app/provider/shorts_provider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/app/ui/pages/shorts/components/short_master_page.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/select_upload_type.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/app/widget/movieCard.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/content.dart';
import '../../../../data/models/shorts.dart';
import '../../../core/utils/sharepreferences.dart';

class ReleasedContentPage extends StatefulWidget {
  const ReleasedContentPage({super.key});

  @override
  State<ReleasedContentPage> createState() => _ReleasedContentPageState();
}

class _ReleasedContentPageState extends State<ReleasedContentPage> {
  String selectedContentType = "MOVIE";
  bool isLoading = true;
  int? _mediaHouseId;
  Timer? _searchDebounce;
  DateTime _startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime _endDate = DateTime.now();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final localPrefs = LocalSharePreferences();
      final mediaHouse = await localPrefs.getMediaHouse();

      if (mediaHouse != null) {
        _mediaHouseId = mediaHouse.id;
        if (!mounted) return;
        final provider = Provider.of<VideoProvider>(context, listen: false);
        provider.searchContentController.clear();
        provider.setItemsPerPage(12);
        provider.resetPagination();
        await _fetchSelectedContent();
      }
    } catch (error) {
      debugPrint("Failed to fetch released content: $error");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _onScroll() {
    if (selectedContentType == "MINI_SERIES") return;
    final provider = Provider.of<VideoProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 160) {
      provider.fetchNextReleasedMoviesPage();
    }
  }

  bool _isSeries(Content movie) {
    final type = (movie.type ?? "").toLowerCase();
    return type.contains("series") || movie.seasonId != null;
  }

  List<Content> _filteredMovies(VideoProvider provider) {
    return provider.filteredContentList.where((movie) {
      final isSeries = _isSeries(movie);
      final typeMatches =
          selectedContentType == "SERIES" ? isSeries : !isSeries;

      return typeMatches;
    }).toList();
  }

  List<ShortModel> _releasedMiniSeries(ShortProvider provider) {
    return provider.shorts.where((short) {
      final approvalStatus = (short.approvalStatus ?? "").toUpperCase();
      return approvalStatus.isEmpty || approvalStatus == "APPROVED";
    }).toList();
  }

  Future<void> _fetchSelectedContent({String? searchKeyword}) async {
    final mediaHouseId = _mediaHouseId;
    if (mediaHouseId == null) return;

    if (selectedContentType == "MINI_SERIES") {
      final shortProvider = context.read<ShortProvider>();
      final keyword = (searchKeyword ??
              context.read<VideoProvider>().searchContentController.text)
          .trim();

      if (keyword.isNotEmpty) {
        await shortProvider.fetchShorts(keyword: keyword, page: 0, size: 12);
      } else {
        await shortProvider.fetchShortsByDateRange(
          startDate: _startDate,
          endDate: _endDate,
          page: 0,
          size: 12,
        );
      }
      return;
    }

    await context.read<VideoProvider>().fetchReleasedMoviesByMediaHouseId(
          mediaHouseId,
          type: selectedContentType,
          searchKeyword: searchKeyword ??
              context.read<VideoProvider>().searchContentController.text.trim(),
          startDate: _formatDate(_startDate),
          endDate: _formatDate(_endDate),
        );
  }

  void _onSearchChanged(String value) {
    final mediaHouseId = _mediaHouseId;
    if (mediaHouseId == null) return;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      await _fetchSelectedContent(searchKeyword: value.trim());
    });
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = DateTime(2020, 1, 1);
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _startDate = _endDate;
        }
      }
    });

    if (_mediaHouseId != null) {
      if (!mounted) return;
      await _fetchSelectedContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer2<VideoProvider, ShortProvider>(
          builder: (context, provider, shortProvider, _) {
            if (isLoading) {
              return Center(
                  child: CircularProgressIndicator(
                color: theme.primaryColor,
              ));
            }

            final movies = _filteredMovies(provider);
            final miniSeries = _releasedMiniSeries(shortProvider);
            final isMiniSeries = selectedContentType == "MINI_SERIES";
            final currentItemCount =
                isMiniSeries ? miniSeries.length : movies.length;

            return Column(
              children: [
                _buildHeader(context, theme, provider, currentItemCount),
                const SizedBox(height: 12),
                Expanded(
                  child: currentItemCount == 0
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 42, color: theme.primaryColor),
                              const SizedBox(height: 8),
                              Text(
                                "No released content found",
                                style: TextStyle(
                                  color: theme.canvasColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveWidget.isDesktop(context) ? 20 : 10,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final crossAxisCount = isMiniSeries
                                  ? width > 1500
                                      ? 5
                                      : width > 1100
                                          ? 4
                                          : width > 760
                                              ? 3
                                              : 2
                                  : width > 1500
                                  ? 4
                                  : width > 1100
                                      ? 3
                                      : width > 760
                                          ? 2
                                          : 1;

                              return GridView.builder(
                                controller: _scrollController,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio:
                                      isMiniSeries ? 9 / 16 : 16 / 9,
                                ),
                                itemCount: currentItemCount +
                                    ((provider.hasMoreReleasedItems ||
                                            provider.isReleasedLoadingMore) &&
                                            !isMiniSeries
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (!isMiniSeries &&
                                      index == movies.length) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    );
                                  }
                                  if (isMiniSeries) {
                                    return _buildMiniSeriesCard(
                                      miniSeries[index],
                                      theme,
                                    );
                                  }

                                  final movie = movies[index];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: MovieCard(
                                      movieId: movie.id!,
                                      movieName: movie.title ?? "",
                                      poster_url:
                                          movie.posterUrlList?.first ?? "",
                                      rating: movie.ratings ?? 0.0,
                                      rating_count: movie.ratingCount ?? 0,
                                      movie: movie,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme,
      VideoProvider provider, int currentItemCount) {
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final isTablet = ResponsiveWidget.isTablet(context);
    final horizontal = isDesktop ? 20.0 : 12.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              theme.cardColor,
              theme.cardColor.withValues(alpha: 0.72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Released Content",
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: ResponsiveWidget.isMobile(context) ? 20 : 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    "$currentItemCount items",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isDesktop || isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: CustomTextField(
                      controller: provider.searchContentController,
                      hintText: "Search released content...",
                      prefixIcon: Icon(Icons.search, color: theme.canvasColor),
                      textInputType: TextInputType.text,
                      onValueChange: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildDateFilters(theme),
                          _buildTypeChips(theme),
                          _buildUploadButton(theme),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: provider.searchContentController,
                    hintText: "Search released content...",
                    prefixIcon: const Icon(Icons.search),
                    textInputType: TextInputType.text,
                    onValueChange: _onSearchChanged,
                  ),
                  const SizedBox(height: 10),
                  _buildDateFilters(theme),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: _buildTypeChips(theme)),
                      const SizedBox(width: 8),
                      _buildUploadButton(theme),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilters(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => _pickDate(isStart: true),
          icon: const Icon(Icons.date_range),
          label: Text("From ${_formatDate(_startDate)}"),
          style: OutlinedButton.styleFrom(
            backgroundColor:
                theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
            side: BorderSide(color: theme.dividerColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _pickDate(isStart: false),
          icon: const Icon(Icons.event),
          label: Text("To ${_formatDate(_endDate)}"),
          style: OutlinedButton.styleFrom(
            backgroundColor:
                theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
            side: BorderSide(color: theme.dividerColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChips(ThemeData theme) {
    return Wrap(
      spacing: 10,
      children: [
        ChoiceChip(
          label: const Text("Movies"),
          selected: selectedContentType == "MOVIE",
          selectedColor: theme.primaryColor,
          backgroundColor:
              theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
          labelStyle: TextStyle(
            color: selectedContentType == "MOVIE"
                ? Colors.white
                : theme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) async {
            if (selectedContentType == "MOVIE") return;
            setState(() => selectedContentType = "MOVIE");
            if (!mounted) return;
            await _fetchSelectedContent();
          },
        ),
        ChoiceChip(
          label: const Text("Series"),
          selected: selectedContentType == "SERIES",
          selectedColor: theme.primaryColor,
          backgroundColor:
              theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
          labelStyle: TextStyle(
            color: selectedContentType == "SERIES"
                ? Colors.white
                : theme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) async {
            if (selectedContentType == "SERIES") return;
            setState(() => selectedContentType = "SERIES");
            if (!mounted) return;
            await _fetchSelectedContent();
          },
        ),
        ChoiceChip(
          label: const Text("Mini Series"),
          selected: selectedContentType == "MINI_SERIES",
          selectedColor: theme.primaryColor,
          backgroundColor:
              theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
          labelStyle: TextStyle(
            color: selectedContentType == "MINI_SERIES"
                ? Colors.white
                : theme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) async {
            if (selectedContentType == "MINI_SERIES") return;
            setState(() => selectedContentType = "MINI_SERIES");
            if (!mounted) return;
            await _fetchSelectedContent();
          },
        ),
      ],
    );
  }

  Widget _buildMiniSeriesCard(ShortModel short, ThemeData theme) {
    return GestureDetector(
      onTap: short.id == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShortMasterPage(shortId: short.id!),
                ),
              );
            },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: theme.cardColor,
              child: Image.network(
                short.posterUrl ?? "",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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
                    short.title ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${short.totalParts ?? 0} parts",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(ThemeData theme) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      icon: const Icon(Icons.file_upload_outlined),
      label: const Text("Upload"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => const SelectUploadTypeDialog(),
        );
      },
    );
  }
}
