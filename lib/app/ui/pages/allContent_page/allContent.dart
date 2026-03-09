import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/app/widget/movieCardHorizontal.dart';
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

  static const List<Map<String, String>> _statusOptions = [
    {"label": "All Uploaded", "value": "ALL"},
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
        child: Consumer<VideoProvider>(
          builder: (context, provider, _) {
            final filtered = _applyLocalSearch(provider.filteredContentList);
            return Column(
              children: [
                _buildHeader(theme, filtered.length, isMobile),
                Expanded(
                  child: _isInitialLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: theme.primaryColor),
                        )
                      : _errorMessage != null
                          ? _buildErrorState(theme)
                          : filtered.isEmpty
                              ? _buildEmptyState(theme)
                              : RefreshIndicator(
                                  onRefresh: () =>
                                      _fetchContent(showLoader: false),
                                  child: _buildContentGrid(
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
        return MovieCardHorizontal(movie: items[index]);
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

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.primaryColor, size: 36),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Something went wrong",
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
