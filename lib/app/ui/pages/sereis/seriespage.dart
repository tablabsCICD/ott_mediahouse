import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/series_provider.dart';
import '../../../widget/movieCardHorizontal.dart';
import '../../../../device/utils/ResponsiveWidget.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'newest';

  DateTime? _parseDate(dynamic rawDate) {
    if (rawDate == null) return null;

    if (rawDate is int) {
      // Supports both unix seconds and milliseconds.
      return rawDate > 9999999999
          ? DateTime.fromMillisecondsSinceEpoch(rawDate)
          : DateTime.fromMillisecondsSinceEpoch(rawDate * 1000);
    }

    return DateTime.tryParse(rawDate.toString());
  }

  bool _isInDateRange(DateTime? date) {
    if (date == null) return true;
    if (_fromDate != null && date.isBefore(_fromDate!)) return false;
    if (_toDate != null) {
      final end = DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
      if (date.isAfter(end)) return false;
    }
    return true;
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _sortBy = 'newest';
    });
  }

  String _formatCompact(num value) {
    if (value >= 10000000) {
      return "${(value / 10000000).toStringAsFixed(1)}Cr";
    }
    if (value >= 100000) {
      return "${(value / 100000).toStringAsFixed(1)}L";
    }
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }
    return value.toStringAsFixed(0);
  }

  Widget _statTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.canvasColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.canvasColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().fetchSeriesByMediaHouseId();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<SeriesProvider>(
        builder: (context, provider, _) {
          final filteredSeries = provider.filteredContentList.where((series) {
            final title = (series.title ?? '').toLowerCase();
            final date = _parseDate(series.releaseDate);
            final searchMatches = _query.isEmpty || title.contains(_query);
            return searchMatches && _isInDateRange(date);
          }).toList();

          filteredSeries.sort((a, b) {
            switch (_sortBy) {
              case 'oldest':
                final aDate = _parseDate(a.releaseDate) ?? DateTime(1970);
                final bDate = _parseDate(b.releaseDate) ?? DateTime(1970);
                return aDate.compareTo(bDate);
              case 'revenue_high':
                return (b.totalRevenue ?? 0).compareTo(a.totalRevenue ?? 0);
              case 'revenue_low':
                return (a.totalRevenue ?? 0).compareTo(b.totalRevenue ?? 0);
              case 'likes_high':
                return (b.ratingCount ?? 0).compareTo(a.ratingCount ?? 0);
              case 'views_high':
                return (b.views ?? 0).compareTo(a.views ?? 0);
              case 'rating_high':
                return (b.ratings ?? 0).compareTo(a.ratings ?? 0);
              case 'newest':
              default:
                final aDate = _parseDate(a.releaseDate) ?? DateTime(1970);
                final bDate = _parseDate(b.releaseDate) ?? DateTime(1970);
                return bDate.compareTo(aDate);
            }
          });

          final totalRevenue = filteredSeries.fold<num>(
            0,
            (sum, item) => sum + (item.totalRevenue ?? 0),
          );
          final totalViews = filteredSeries.fold<num>(
            0,
            (sum, item) => sum + (item.views ?? 0),
          );
          final totalLikes = filteredSeries.fold<num>(
            0,
            (sum, item) => sum + (item.ratingCount ?? 0),
          );

          return RefreshIndicator(
            onRefresh: provider.fetchSeriesByMediaHouseId,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Series Management",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.canvasColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      final tileWidth =
                          isWide ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: tileWidth,
                            child: _statTile(
                              theme,
                              icon: Icons.video_collection_outlined,
                              label: "Series Count",
                              value: "${filteredSeries.length}",
                              accent: Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: _statTile(
                              theme,
                              icon: Icons.visibility_outlined,
                              label: "Total Views",
                              value: _formatCompact(totalViews),
                              accent: Colors.orange,
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: _statTile(
                              theme,
                              icon: Icons.currency_rupee_rounded,
                              label: "Total Revenue",
                              value: _formatCompact(totalRevenue),
                              accent: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 900;

                        final searchField = TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: "Search series by title...",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _searchCtrl.clear(),
                                  ),
                          ),
                        );

                        final filters = Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickFromDate,
                              icon: const Icon(Icons.date_range, size: 18),
                              label: Text(
                                _fromDate == null
                                    ? "From"
                                    : "${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}",
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickToDate,
                              icon: const Icon(Icons.event, size: 18),
                              label: Text(
                                _toDate == null
                                    ? "To"
                                    : "${_toDate!.day}/${_toDate!.month}/${_toDate!.year}",
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _sortBy,
                                  dropdownColor: theme.cardColor,
                                  style: TextStyle(color: theme.canvasColor),
                                  iconEnabledColor: theme.canvasColor,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _sortBy = value;
                                      });
                                    }
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: 'newest',
                                      child: Text("Newest", style: TextStyle(color: theme.canvasColor)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'oldest',
                                      child: Text("Oldest", style: TextStyle(color: theme.canvasColor)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'revenue_high',
                                      child: Text("Revenue High", style: TextStyle(color: theme.canvasColor)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'revenue_low',
                                      child: Text("Revenue Low", style: TextStyle(color: theme.canvasColor)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'likes_high',
                                      child: Text("Likes High", style: TextStyle(color: theme.canvasColor)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'views_high',
                                      child: Text("Views High", style: TextStyle(color: theme.canvasColor)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'rating_high',
                                      child: Text("Rating High", style: TextStyle(color: theme.canvasColor)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _resetFilters,
                              child: const Text("Reset"),
                            ),
                          ],
                        );

                        if (isCompact) {
                          return Column(
                            children: [
                              searchField,
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: filters,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: searchField),
                            const SizedBox(width: 12),
                            Expanded(flex: 5, child: Align(
                              alignment: Alignment.centerRight,
                              child: filters,
                            )),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredSeries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          _query.isEmpty
                              ? "No series available."
                              : "No series found for current filters.",
                          style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.75)),
                        ),
                      ),
                    )
                  else
                    ResponsiveWidget.isMobile(context)
                        ? ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredSeries.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return MovieCardHorizontal(movie: filteredSeries[index]);
                            },
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredSeries.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 8 / 4,
                            ),
                            itemBuilder: (context, index) {
                              return MovieCardHorizontal(movie: filteredSeries[index]);
                            },
                          ),
                  if (filteredSeries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                      child: Text(
                        "Likes: ${_formatCompact(totalLikes)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.canvasColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
