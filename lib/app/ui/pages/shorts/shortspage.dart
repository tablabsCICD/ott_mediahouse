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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 4
        : ResponsiveWidget.isTablet(context)
            ? 4
            : 2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<ShortProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.shorts.isEmpty) {
            return Center(
                child: CircularProgressIndicator(
              color: theme.primaryColor,
            ));
          }

          if (provider.shorts.isEmpty) {
            return Center(
              child: Text(
                "No short films available",
                style: TextStyle(color: theme.canvasColor),
              ),
            );
          }

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 900;

                    final searchField = SizedBox(
                      width: isCompact ? double.infinity : 420,
                      child: CustomTextField(
                        controller: _searchCtrl,
                        hintText: "Search shorts...",
                        textInputType: TextInputType.text,
                        prefixIcon: const Icon(Icons.search),
                        onValueChange: (_) => setState(() {}),
                      ),
                    );

                    final filterBar = Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                                  child: Text("Newest",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'oldest',
                                  child: Text("Oldest",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'views_high',
                                  child: Text("Views High",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'likes_high',
                                  child: Text("Likes High",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'parts_high',
                                  child: Text("Parts High",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'coins_high',
                                  child: Text("Coins High",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'trending_first',
                                  child: Text("Trending First",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'title_az',
                                  child: Text("Title A-Z",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                                DropdownMenuItem(
                                  value: 'title_za',
                                  child: Text("Title Z-A",
                                      style:
                                          TextStyle(color: theme.canvasColor)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text("Reset"),
                        ),
                      ],
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          searchField,
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.centerRight,
                              child: filterBar),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: filterBar,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (filteredShorts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "No shorts found for current filters",
                      style: TextStyle(color: theme.canvasColor),
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
