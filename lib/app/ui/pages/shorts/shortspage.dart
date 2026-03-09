import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/shorts_provider.dart';
import 'package:media_house/app/ui/pages/shorts/components/add_short_master.dart';
import 'package:media_house/app/ui/pages/shorts/components/short_master_page.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _query = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'newest';
  String? _trendingLanguage;
  static const List<String> _trendingLanguages = [
    'Marathi',
    'Hindi',
    'English',
    'Gujarati',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Punjabi',
    'Bengali',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      _query = _searchCtrl.text.trim();
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _loadShortsFromFilters();
      });
    });
    context.read<ShortProvider>().fetchShorts(page: 0, size: 10);
  }

  Future<void> _loadShortsFromFilters() async {
    final provider = context.read<ShortProvider>();
    if (_sortBy == 'trending_first') {
      await provider.fetchTrendingShorts(
        lang: _trendingLanguage,
        page: 0,
        size: 10,
      );
      return;
    }
    if (_fromDate != null && _toDate != null) {
      await provider.fetchShortsByDateRange(
        startDate: _fromDate!,
        endDate: _toDate!,
        page: 0,
        size: 10,
      );
      return;
    }
    await provider.fetchShorts(
      keyword: _query,
      page: 0,
      size: 10,
    );
  }

  String get _selectedTrendingLanguageText =>
      _trendingLanguage == null ? 'All Languages' : _trendingLanguage!;

  Future<void> _pickTrendingLanguagePopup() async {
    const allValue = '__ALL__';
    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final activeLanguage = _trendingLanguage;
        Widget buildOption({
          required String value,
          required String label,
          required bool selected,
        }) {
          return ListTile(
            dense: true,
            leading: Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: selected
                  ? theme.primaryColor
                  : theme.canvasColor.withValues(alpha: 0.6),
            ),
            title: Text(label),
            onTap: () => Navigator.pop(dialogContext, value),
          );
        }

        return AlertDialog(
          title: const Text('Select Trending Language'),
          content: SizedBox(
            width: 320,
            child: ListView(
              shrinkWrap: true,
              children: [
                buildOption(
                  value: allValue,
                  label: 'All Languages',
                  selected: activeLanguage == null,
                ),
                ..._trendingLanguages.map(
                  (language) => buildOption(
                    value: language,
                    label: language,
                    selected: activeLanguage == language,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      _trendingLanguage = picked == allValue ? null : picked;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 560,
            child: DateRangePickerDialog(
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialDateRange: (_fromDate != null && _toDate != null)
                  ? DateTimeRange(start: _fromDate!, end: _toDate!)
                  : null,
              helpText: 'Select Date Range',
              confirmText: 'Apply',
              cancelText: 'Cancel',
            ),
          ),
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _fromDate = picked.start;
      _toDate = picked.end;
    });
    await _loadShortsFromFilters();
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
      _fromDate = null;
      _toDate = null;
      _sortBy = 'newest';
    });
    context.read<ShortProvider>().fetchShorts(page: 0, size: 10);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveWidget.isMobile(context);
    final isDesktop = ResponsiveWidget.isDesktop(context);

    final crossAxisCount = isDesktop
        ? 5
        : ResponsiveWidget.isTablet(context)
            ? 3
            : 2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<ShortProvider>(
        builder: (context, provider, _) {
          final loadedShorts = provider.shorts;
          final totalItems = loadedShorts.length + 1;
          final countLabel = provider.shortsTotalItems > 0
              ? provider.shortsTotalItems
              : loadedShorts.length;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                _buildTopAndFilterPanel(theme, countLabel),
                const SizedBox(height: 8),
                if (provider.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: LinearProgressIndicator(
                      color: theme.primaryColor,
                      backgroundColor:
                          theme.dividerColor.withValues(alpha: 0.25),
                    ),
                  ),
                if (loadedShorts.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 42, color: theme.primaryColor),
                        const SizedBox(height: 8),
                        Text(
                          "No shorts found for current filters",
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: totalItems,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      // Exact vertical short ratio
                      childAspectRatio: 9 / 16,
                    ),
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return _buildAddShortTile(theme);
                      }

                      final short = loadedShorts[index - 1];
                      return _buildShortTile(short, theme);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {
          AddShortMaster.show(context);
        },
        tooltip: 'Add Short',
        child: const Icon(
          Icons.play_circle_fill_sharp,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTopPanel(ThemeData theme, int count) {
    return Row(
      children: [
        Icon(Icons.video_collection_rounded, color: theme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Shorts Library",
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$count items",
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadShortsFromFilters,
          icon: const Icon(Icons.refresh_rounded),
        )
      ],
    );
  }

  Widget _buildTopAndFilterPanel(ThemeData theme, int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.cardColor.withValues(alpha: 0.95),
                theme.cardColor.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              _buildTopPanel(theme, count),
              const SizedBox(height: 12),
              compact
                  ? Column(
                      children: [
                        _buildSearchField(theme),
                        const SizedBox(height: 10),
                        _buildFilterActions(theme, compact: true),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(flex: 2, child: _buildSearchField(theme)),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: _buildFilterActions(theme, compact: false),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return CustomTextField(
      controller: _searchCtrl,
      hintText: "Search title, parts, trending...",
      textInputType: TextInputType.text,
      prefixIcon: Icon(
        Icons.search,
        color: theme.canvasColor,
      ),
    );
  }

  Widget _buildFilterActions(ThemeData theme, {required bool compact}) {
    final dateText = (_fromDate != null && _toDate != null)
        ? "${_formatDate(_fromDate!)} - ${_formatDate(_toDate!)}"
        : "Select Date Range";

    final dateButton = OutlinedButton.icon(
      onPressed: _pickDateRange,
      icon: const Icon(Icons.calendar_month_rounded, size: 18),
      label: Text(dateText, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.canvasColor,
        side: BorderSide(color: theme.dividerColor),
      ),
    );

    final resetButton = TextButton.icon(
      onPressed: _resetFilters,
      icon: const Icon(Icons.restart_alt_rounded, size: 16),
      label: const Text("Reset"),
    );

    final trendingChip = FilterChip(
      selected: _sortBy == 'trending_first',
      label: const Text('Trending'),
      onSelected: (selected) async {
        if (selected) {
          setState(() => _sortBy = 'trending_first');
          await _pickTrendingLanguagePopup();
          await _loadShortsFromFilters();
          return;
        }
        setState(() => _sortBy = 'newest');
        await _loadShortsFromFilters();
      },
      backgroundColor: theme.cardColor.withValues(alpha: 0.7),
      selectedColor: theme.primaryColor.withValues(alpha: 0.18),
      checkmarkColor: theme.primaryColor,
      side: BorderSide(
        color: _sortBy == 'trending_first'
            ? theme.primaryColor.withValues(alpha: 0.9)
            : theme.dividerColor.withValues(alpha: 0.6),
      ),
      labelStyle: TextStyle(
        color: _sortBy == 'trending_first'
            ? theme.primaryColor
            : theme.canvasColor.withValues(alpha: 0.88),
        fontWeight: FontWeight.w600,
      ),
    );

    final trendingLanguageTag = InkWell(
      onTap: _sortBy == 'trending_first'
          ? () async {
              await _pickTrendingLanguagePopup();
              await _loadShortsFromFilters();
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        constraints: const BoxConstraints(minWidth: 120),
        alignment: Alignment.center,
        child: Text(
          _selectedTrendingLanguageText,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.88),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    final trendingLanguageWrap = Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: trendingLanguageTag,
    );

    if (compact) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          SizedBox(width: 240, child: dateButton),
          trendingChip,
          if (_sortBy == 'trending_first') trendingLanguageWrap,
          resetButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: dateButton),
        const SizedBox(width: 8),
        trendingChip,
        if (_sortBy == 'trending_first') ...[
          const SizedBox(width: 8),
          SizedBox(width: 150, child: trendingLanguageWrap),
        ],
        const SizedBox(width: 6),
        resetButton,
      ],
    );
  }

  Widget _buildAddShortTile(ThemeData theme) {
    return GestureDetector(
      onTap: () => AddShortMaster.show(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.4),
            width: 1.3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 56, child: Image.asset(ImageConstant.upload)),
              const SizedBox(height: 16),
              Text(
                "Add New Short",
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortTile(dynamic short, ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        final deleted = await navigator.push<bool>(
          MaterialPageRoute(
            builder: (_) => ShortMasterPage(
              shortId: short.id,
            ),
          ),
        );

        if (deleted == true) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text("Short deleted successfully"),
              behavior: SnackBarBehavior.floating,
            ),
          );

          _loadShortsFromFilters();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: theme.cardColor,
              child: Image.network(
                short.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (short.isTrending == true)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "TRENDING",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
                    short.title ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${short.totalParts ?? 0} Parts",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 10,
              right: 10,
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }
}
