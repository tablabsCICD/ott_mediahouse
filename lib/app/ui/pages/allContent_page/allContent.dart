import 'package:flutter/material.dart';
import 'package:media_house/app/provider/shorts_provider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/app/ui/pages/shorts/components/short_master_page.dart';
import 'package:media_house/app/widget/agreementMovieCard.dart';
import 'package:media_house/app/widget/movieCardHorizontal.dart';
import 'package:media_house/data/models/shorts.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/content.dart';
import '../../../core/utils/sharepreferences.dart';

class AllContentPage extends StatefulWidget {
  const AllContentPage({super.key});

  @override
  State<AllContentPage> createState() => _AllContentPageState();
}

class _AllContentPageState extends State<AllContentPage> {
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;

  String _selectedStatus = "ALL";
  String _selectedType = "MOVIE";
  String _searchQuery = "";
  bool _isInitialLoading = true;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;
  static const String _miniSeriesType = "MINI_SERIES";

  bool get _isMiniSeriesSelected => _selectedType == _miniSeriesType;

  static const List<Map<String, String>> _statusOptions = [
    {"label": "All Uploaded", "value": "ALL"},
    {"label": "Pending Agreement", "value": "PENDING"},
    {"label": "Pending", "value": "PENDING"},
    {"label": "Approved", "value": "APPROVED"},
    {"label": "Rejected", "value": "REJECTED"},
    {"label": "Upcoming", "value": "UPCOMING"},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
      context.read<VideoProvider>().resetPagination();
    });

    _fetchContent(showLoader: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchContent({required bool showLoader}) async {
    if (showLoader) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
      });
    }

    try {
      if (_isMiniSeriesSelected) {
        final shortProvider = context.read<ShortProvider>();
        if (_startDate != null && _endDate != null) {
          await shortProvider.fetchShortsByDateRange(
            startDate: _startDate!,
            endDate: _endDate!,
            page: 0,
            size: 30,
          );
        } else {
          await shortProvider.fetchShorts(page: 0, size: 30);
        }
      } else {
        final localPrefs = LocalSharePreferences();
        final mediaHouse = await localPrefs.getMediaHouse();
        if (mediaHouse?.id == null) {
          setState(() {
            _errorMessage = "Production house not found. Please login again.";
          });
          return;
        }
        if (!mounted) return;

        final provider = context.read<VideoProvider>();
        provider.setItemsPerPage(10);
        provider.resetPagination();
        await provider.fetchMoviesByStatusAndMediaHouseId(
          _selectedStatus,
          mediaHouse!.id!,
          type: _selectedType,
          startDate: _startDate == null ? null : _formatDate(_startDate!),
          endDate: _endDate == null ? null : _formatDate(_endDate!),
        );
      }
    } catch (_) {
      setState(() {
        _errorMessage = "Failed to load content. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    final provider = context.read<VideoProvider>();
    if (_isMiniSeriesSelected) return;
    if (provider.isStatusLoadingMore || !provider.hasMoreStatusItems) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      provider.fetchNextMoviesByStatusAndMediaHousePage();
    }
  }

  List<Content> _applyLocalSearch(List<Content> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((content) {
      final title = (content.title ?? "").toLowerCase();
      final type = (content.type ?? "").toLowerCase();
      final ageRating = (content.ageRating ?? "").toLowerCase();
      return title.contains(_searchQuery) ||
          type.contains(_searchQuery) ||
          ageRating.contains(_searchQuery);
    }).toList();
  }

  List<ShortModel> _applyMiniSeriesFilters(List<ShortModel> items) {
    Iterable<ShortModel> result = items;
    if (_selectedStatus != "ALL") {
      result = result.where((short) =>
          (short.approvalStatus ?? '').toUpperCase() == _selectedStatus);
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((short) {
        final title = (short.title ?? '').toLowerCase();
        final creator = (short.creatorName ?? '').toLowerCase();
        final category = (short.category ?? '').toLowerCase();
        return title.contains(_searchQuery) ||
            creator.contains(_searchQuery) ||
            category.contains(_searchQuery);
      });
    }
    return result.toList();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate;
        }
      }
    });
    await _fetchContent(showLoader: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final isMobile = ResponsiveWidget.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer2<VideoProvider, ShortProvider>(
          builder: (context, provider, shortProvider, _) {
            final filtered = _applyLocalSearch(provider.filteredContentList);
            final miniSeries =
                _applyMiniSeriesFilters(shortProvider.shorts);
            final visibleCount =
                _isMiniSeriesSelected ? miniSeries.length : filtered.length;
            final isLoading = _isInitialLoading ||
                (_isMiniSeriesSelected && shortProvider.isLoading);
            final errorMessage =
                _isMiniSeriesSelected ? shortProvider.shortsError : _errorMessage;
            return Column(
              children: [
                _buildHeader(theme, visibleCount, isMobile),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: theme.primaryColor),
                        )
                      : errorMessage != null
                          ? _buildErrorState(theme, errorMessage)
                          : visibleCount == 0
                              ? _buildEmptyState(theme)
                              : RefreshIndicator(
                                  onRefresh: () =>
                                      _fetchContent(showLoader: false),
                                  child: _isMiniSeriesSelected
                                      ? _buildMiniSeriesGrid(
                                          theme: theme,
                                          items: miniSeries,
                                        )
                                      : _buildContentGrid(
                                          theme: theme,
                                          items: filtered,
                                          provider: provider,
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

  Widget _buildHeader(ThemeData theme, int count, bool isMobile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
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
          color: theme.dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "All Content",
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "$count items",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search title, type, age rating...",
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.canvasColor,
              ),
              suffixIcon: IconButton(
                onPressed: () => _fetchContent(showLoader: false),
                icon: const Icon(Icons.refresh_rounded),
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDateButton(
                      theme,
                      _startDate == null
                          ? "Select From Date"
                          : "From ${_formatShortDate(_startDate!)}",
                      true,
                    ),
                    _buildDateButton(
                      theme,
                      _endDate == null
                          ? "Select To Date"
                          : "To ${_formatShortDate(_endDate!)}",
                      false,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip(theme, "MOVIE", "Movies"),
                    _buildTypeChip(theme, "SERIES", "Series"),
                    _buildTypeChip(theme, _miniSeriesType, "Mini Series"),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                _buildTypeChip(theme, "MOVIE", "Movies"),
                const SizedBox(width: 8),
                _buildTypeChip(theme, "SERIES", "Series"),
                const SizedBox(width: 8),
                _buildTypeChip(theme, _miniSeriesType, "Mini Series"),
                const Spacer(),
                _buildDateButton(
                    theme,
                    _startDate == null
                        ? "Select From Date"
                        : "From ${_formatDate(_startDate!)}",
                    true),
                const SizedBox(width: 8),
                _buildDateButton(
                    theme,
                    _endDate == null
                        ? "Select To Date"
                        : "To ${_formatDate(_endDate!)}",
                    false),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = _statusOptions[index];
                final value = option["value"]!;
                final selected = _selectedStatus == value;
                return ChoiceChip(
                  label: Text(option["label"]!),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: theme.primaryColor,
                  backgroundColor:
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : theme.canvasColor,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) async {
                    if (selected) return;
                    setState(() => _selectedStatus = value);
                    await _fetchContent(showLoader: true);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme, String value, String label) {
    final selected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: theme.primaryColor,
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
      labelStyle: TextStyle(
        color: selected ? Colors.white : theme.canvasColor,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) async {
        if (selected) return;
        setState(() => _selectedType = value);
        await _fetchContent(showLoader: true);
      },
    );
  }

  Widget _buildDateButton(ThemeData theme, String label, bool isStart) {
    return OutlinedButton(
      onPressed: () => _pickDate(isStart: isStart),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: theme.dividerColor),
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }

  String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return "$day/$month/$year";
  }

  Widget _buildContentGrid({
    required ThemeData theme,
    required List<Content> items,
    required VideoProvider provider,
  }) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1500
        ? 3
        : width > 1280
            ? 3
            : width > 1000
                ? 2
                : width > 700
                    ? 2
                    : 1;

    final hasMore = provider.hasMoreStatusItems;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: items.length + (hasMore ? 1 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return _buildLoadMore(theme);
        }
        final item = items[index];
        final needsAgreement = item.isAggrement != true;
        return needsAgreement
            ? AgreementMovieCard(movie: item, theme: theme)
            : MovieCardHorizontal(movie: item);
      },
    );
  }

  Widget _buildLoadMore(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          const SizedBox(height: 8),
          Text(
            "Loading more...",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.72),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSeriesGrid({
    required ThemeData theme,
    required List<ShortModel> items,
  }) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1500
        ? 5
        : width > 1180
            ? 4
            : width > 820
                ? 3
                : width > 560
                    ? 2
                    : 1;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return _buildMiniSeriesCard(theme, items[index]);
      },
    );
  }

  Widget _buildMiniSeriesCard(ThemeData theme, ShortModel short) {
    final status = (short.approvalStatus ?? 'PENDING').toUpperCase();
    final statusColor = status == 'APPROVED'
        ? const Color(0xFF22C55E)
        : status == 'REJECTED'
            ? const Color(0xFFEF4444)
            : const Color(0xFFF59E0B);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final id = short.id;
        if (id == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShortMasterPage(shortId: id)),
        );
        if (mounted) {
          await _fetchContent(showLoader: false);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.45)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                short.posterUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.scaffoldBackgroundColor,
                  child: Icon(
                    Icons.smart_display_outlined,
                    color: theme.primaryColor,
                    size: 42,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: _miniBadge(
                label: 'MINI SERIES',
                color: theme.primaryColor,
              ),
            ),
            if (short.isTrending == true)
              Positioned(
                top: 10,
                right: 10,
                child: _miniBadge(
                  label: 'TRENDING',
                  color: const Color(0xFFF59E0B),
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
                    short.title ?? 'Untitled Mini Series',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    short.creatorName?.trim().isNotEmpty == true
                        ? 'Creator: ${short.creatorName}'
                        : 'Creator: N/A',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _miniInfoPill(Icons.play_arrow_rounded,
                          '${short.totalParts ?? 0} Parts'),
                      _miniInfoPill(Icons.monetization_on_outlined,
                          '${short.coinsPerPart ?? 0} Coins'),
                      _miniBadge(label: status, color: statusColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _miniInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, [String? message]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.primaryColor, size: 36),
            const SizedBox(height: 8),
            Text(
              message ?? _errorMessage ?? "Something went wrong",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.canvasColor),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _fetchContent(showLoader: true),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 42, color: theme.primaryColor),
          const SizedBox(height: 8),
          Text(
            "No content found",
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
