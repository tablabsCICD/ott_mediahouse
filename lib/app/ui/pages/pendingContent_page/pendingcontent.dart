import 'package:flutter/material.dart';
import 'package:media_house/app/widget/content_wide_card.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/content.dart';
import '../../../core/utils/sharepreferences.dart';

class PendingContentPage extends StatefulWidget {
  const PendingContentPage({super.key});

  @override
  State<PendingContentPage> createState() => _PendingContentPageState();
}

class _PendingContentPageState extends State<PendingContentPage> {
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;

  String _selectedStatus = "ALL";
  String _searchQuery = "";
  bool _isInitialLoading = true;
  String? _errorMessage;
  int _lastFilteredCount = 0;

  static const List<Map<String, String>> _statusOptions = [
    {"label": "All Uploaded", "value": "ALL"},
    {"label": "Pending", "value": "PENDING"},
    {"label": "Approved", "value": "APPROVED"},
    {"label": "Rejected", "value": "REJECTED"},
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
          _errorMessage = "Media house not found. Please login again.";
        });
        return;
      }

      final provider = context.read<VideoProvider>();
      provider.setItemsPerPage(10);
      provider.resetPagination();
      await provider.fetchMoviesByStatusAndMediaHouseId(
        _selectedStatus,
        mediaHouse!.id!,
      );
    } catch (e) {
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
    if (_lastFilteredCount <= 0 || provider.isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      provider.loadNextPageForCount(_lastFilteredCount);
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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),
            Expanded(
              child: Consumer<VideoProvider>(
                builder: (context, provider, _) {
                  if (_isInitialLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                      ),
                    );
                  }

                  if (_errorMessage != null) {
                    return _buildErrorState(theme);
                  }

                  final filtered =
                      _applyLocalSearch(provider.filteredContentList);
                  _lastFilteredCount = filtered.length;

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No content found",
                        style: TextStyle(color: theme.canvasColor),
                      ),
                    );
                  }

                  final visibleCount =
                      provider.visibleCountFor(filtered.length);
                  final displayedItems = filtered.take(visibleCount).toList();
                  final hasMore = provider.hasMoreForCount(filtered.length);

                  return RefreshIndicator(
                    onRefresh: () => _fetchContent(showLoader: false),
                    child: ResponsiveWidget.isMobile(context)
                        ? _buildMobileList(
                            displayedItems: displayedItems,
                            hasMore: hasMore,
                            provider: provider,
                            theme: theme,
                          )
                        : _buildDesktopGrid(
                            displayedItems: displayedItems,
                            hasMore: hasMore,
                            provider: provider,
                            theme: theme,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    final isMobile = ResponsiveWidget.isMobile(context);
    final isTablet = ResponsiveWidget.isTablet(context);
    final horizontalPadding = isMobile ? 12.0 : 20.0;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Pending Content",
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!isMobile)
                TextButton.icon(
                  onPressed: () => _fetchContent(showLoader: false),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search content...",
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: isMobile ? 42 : 44,
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
                  backgroundColor: theme.cardColor,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : theme.canvasColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (_) async {
                    if (selected) return;
                    setState(() {
                      _selectedStatus = value;
                    });
                    await _fetchContent(showLoader: true);
                  },
                );
              },
            ),
          ),
          if (isTablet) const SizedBox(height: 2),
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

  Widget _buildMobileList({
    required List<Content> displayedItems,
    required bool hasMore,
    required VideoProvider provider,
    required ThemeData theme,
  }) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
      itemCount: displayedItems.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayedItems.length) {
          return _buildLoadMore(theme, provider);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ContentWideCard(content: displayedItems[index]),
        );
      },
    );
  }

  Widget _buildDesktopGrid({
    required List<Content> displayedItems,
    required bool hasMore,
    required VideoProvider provider,
    required ThemeData theme,
  }) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1440
        ? 4
        : width > 1080
            ? 3
            : 2;

    return Stack(
      children: [
        GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
          itemCount: displayedItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 16 / 9,
          ),
          itemBuilder: (context, index) {
            return ContentWideCard(content: displayedItems[index]);
          },
        ),
        if (hasMore)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildLoadMore(theme, provider),
          ),
      ],
    );
  }

  Widget _buildLoadMore(ThemeData theme, VideoProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: theme.primaryColor,
          ),
          const SizedBox(height: 6),
          Text(
            provider.getPageInfo(),
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
