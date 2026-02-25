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
  String _query = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });
    context.read<ShortProvider>().fetchShorts();
  }

  DateTime? _parseDate(dynamic rawDate) {
    if (rawDate == null) return null;
    if (rawDate is int) {
      return rawDate > 9999999999
          ? DateTime.fromMillisecondsSinceEpoch(rawDate)
          : DateTime.fromMillisecondsSinceEpoch(rawDate * 1000);
    }
    return DateTime.tryParse(rawDate.toString());
  }

  bool _inDateRange(DateTime? date) {
    if (date == null) return true;
    if (_fromDate != null && date.isBefore(_fromDate!)) return false;
    if (_toDate != null) {
      final end =
          DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
      if (date.isAfter(end)) return false;
    }
    return true;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: (_fromDate != null && _toDate != null)
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (picked == null) return;
    setState(() {
      _fromDate = picked.start;
      _toDate = picked.end;
    });
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _sortBy = 'newest';
    });
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
          final filteredShorts = provider.shorts.where((short) {
            final title = (short.title ?? '').toLowerCase();
            final date = _parseDate(short.createdAt ?? short.createdDate);
            final matchesSearch = _query.isEmpty || title.contains(_query);
            return matchesSearch && _inDateRange(date);
          }).toList();

          filteredShorts.sort((a, b) {
            switch (_sortBy) {
              case 'views_high':
                return (b.viewCount ?? 0).compareTo(a.viewCount ?? 0);
              case 'likes_high':
                return (b.likeCount ?? 0).compareTo(a.likeCount ?? 0);
              case 'parts_high':
                return (b.totalParts ?? 0).compareTo(a.totalParts ?? 0);
              case 'coins_high':
                return (b.coinsPerPart ?? 0).compareTo(a.coinsPerPart ?? 0);
              case 'title_az':
                return (a.title ?? '').compareTo(b.title ?? '');
              case 'title_za':
                return (b.title ?? '').compareTo(a.title ?? '');
              case 'trending_first':
                return (b.isTrending == true ? 1 : 0)
                    .compareTo(a.isTrending == true ? 1 : 0);
              case 'oldest':
                final aDate =
                    _parseDate(a.createdAt ?? a.createdDate) ?? DateTime(1970);
                final bDate =
                    _parseDate(b.createdAt ?? b.createdDate) ?? DateTime(1970);
                return aDate.compareTo(bDate);
              case 'newest':
              default:
                final aDate =
                    _parseDate(a.createdAt ?? a.createdDate) ?? DateTime(1970);
                final bDate =
                    _parseDate(b.createdAt ?? b.createdDate) ?? DateTime(1970);
                return bDate.compareTo(aDate);
            }
          });

          final totalItems = filteredShorts.length + 1;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                _buildTopAndFilterPanel(theme, filteredShorts.length),
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
                if (filteredShorts.isEmpty)
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

                      final short = filteredShorts[index - 1];
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
          onPressed: () => context.read<ShortProvider>().fetchShorts(),
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
      onValueChange: (_) => setState(() {}),
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
      onSelected: (_) {
        setState(() {
          _sortBy = _sortBy == 'trending_first' ? 'newest' : 'trending_first';
        });
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

    if (compact) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          SizedBox(width: 240, child: dateButton),
          trendingChip,
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
        final shortProvider = context.read<ShortProvider>();

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

          shortProvider.fetchShorts();
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
    _searchCtrl.dispose();
    super.dispose();
  }
}
