import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_house/app/provider/graphProvider.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/MovieDetailsPage.dart';
import 'package:media_house/app/widget/TopMoviesLineGraph.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/data/models/response/reportAndDataResponse.dart';
import 'package:provider/provider.dart';
import 'package:media_house/app/provider/themeProvider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isAscending = true;
  bool _sortByRevenue = true;
  final NumberFormat _numberFormat = NumberFormat("#,##0.##");
  String _reportContentType = 'ALL';
  String _reportCountry = '';
  String _reportState = '';
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  DateTimeRange? _reportDateRange;

  static const List<String> _contentTypeOptions = ['ALL', 'MOVIE', 'SERIES'];

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  void _toggleSortCriteria() {
    setState(() {
      _sortByRevenue = !_sortByRevenue;
    });
  }

  List<ReportAndDataObject> getSortedMovies(GraphProvider provider) {
    List<ReportAndDataObject> sortedMovies =
        List.from(provider.reportAndDataList);
    sortedMovies.sort((a, b) {
      if (_sortByRevenue) {
        return _isAscending
            ? _toDouble(a.netRevenue).compareTo(_toDouble(b.netRevenue))
            : _toDouble(b.netRevenue).compareTo(_toDouble(a.netRevenue));
      } else {
        return _isAscending
            ? (a.movieName ?? '').compareTo(b.movieName ?? '')
            : (b.movieName ?? '').compareTo(a.movieName ?? '');
      }
    });
    return sortedMovies;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatNumber(num value) {
    return _numberFormat.format(value);
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selectedThemeData.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        selectedThemeData.primaryColor.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: selectedThemeData.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieTable(
      List<ReportAndDataObject> movies, ThemeData selectedThemeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _toggleSortCriteria,
              icon: const Icon(Icons.swap_horiz),
              label: Text(_sortByRevenue ? "Sort: Revenue" : "Sort: Name"),
            ),
            OutlinedButton.icon(
              onPressed: _toggleSortOrder,
              icon: Icon(_isAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded),
              label: Text(_isAscending ? "Ascending" : "Descending"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selectedThemeData.primaryColor,
                  ),
                  columns: const [
                    DataColumn(label: Text("Content")),
                    DataColumn(label: Text("Release Date")),
                    DataColumn(label: Text("Views"), numeric: true),
                    DataColumn(label: Text("Revenue"), numeric: true),
                    DataColumn(label: Text("Commission %"), numeric: true),
                    DataColumn(label: Text("Net Revenue"), numeric: true),
                    DataColumn(label: Text("Details")),
                  ],
                  rows: movies
                      .map(
                        (movie) => DataRow(
                          cells: [
                            DataCell(Text(movie.movieName ?? '-')),
                            DataCell(Text("${movie.releasedDate ?? '-'}")),
                            DataCell(Text(_formatNumber(_toInt(movie.views)))),
                            DataCell(
                                Text(_formatNumber(_toDouble(movie.revenue)))),
                            DataCell(
                                Text("${movie.percentageMediaHouse ?? 0}%")),
                            DataCell(
                                Text(_formatNumber(_toInt(movie.netRevenue)))),
                            DataCell(
                              TextButton(
                                onPressed: movie.views == null
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MovieDetailsPage(
                                              movieId: movie.views!,
                                            ),
                                          ),
                                        );
                                      },
                                child: const Text("Open"),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _reportDateRange =
        DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    _initData();
  }

  @override
  void dispose() {
    _districtController.dispose();
    _talukaController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final provider = Provider.of<GraphProvider>(context, listen: false);
    await provider.fetchCountriesIfNeeded();
    await _applyReportFilters();
  }

  Future<void> _applyReportFilters() async {
    final district = _districtController.text.trim();
    final taluka = _talukaController.text.trim();
    final city = _cityController.text.trim();

    if (_reportCountry.isEmpty &&
        (_reportState.isNotEmpty ||
            district.isNotEmpty ||
            taluka.isNotEmpty ||
            city.isNotEmpty)) {
      CustomToast.show("Select country first.", isSuccess: false);
      return;
    }
    if (_reportState.isEmpty &&
        (district.isNotEmpty || taluka.isNotEmpty || city.isNotEmpty)) {
      CustomToast.show("Select state after country.", isSuccess: false);
      return;
    }
    if (district.isEmpty && (taluka.isNotEmpty || city.isNotEmpty)) {
      CustomToast.show("Enter district before taluka/city.", isSuccess: false);
      return;
    }
    if (taluka.isEmpty && city.isNotEmpty) {
      CustomToast.show("Enter taluka before city.", isSuccess: false);
      return;
    }

    final provider = Provider.of<GraphProvider>(context, listen: false);
    await provider.getReportAndData(
      context,
      contentType: _reportContentType,
      country: _reportCountry,
      state: _reportState,
      district: district,
      taluka: taluka,
      city: city,
      startDate: _reportDateRange?.start,
      endDate: _reportDateRange?.end,
    );
  }

  Future<void> _clearReportFilters() async {
    final provider = Provider.of<GraphProvider>(context, listen: false);
    setState(() {
      _reportContentType = 'ALL';
      _reportCountry = '';
      _reportState = '';
      _districtController.clear();
      _talukaController.clear();
      _cityController.clear();
      final now = DateTime.now();
      _reportDateRange = DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
    });
    provider.clearStateOptions();
    await _applyReportFilters();
  }

  Future<void> _pickReportDateRange() async {
    final initial = _reportDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
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
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: initial,
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
      _reportDateRange = picked;
    });
  }

  Future<String?> _showSearchableSelectionDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String initialValue,
    required ThemeData theme,
  }) async {
    final searchController = TextEditingController();
    var filtered = List<String>.from(options);

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 420,
                height: 480,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.canvasColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(
                              Icons.close,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          final query = value.trim().toLowerCase();
                          setStateDialog(() {
                            filtered = options
                                .where((e) => e.toLowerCase().contains(query))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search...",
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.canvasColor,
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext, ''),
                          child: Text(
                            "Clear Selection",
                            style: TextStyle(color: theme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  "No country found.",
                                  style: TextStyle(
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: theme.dividerColor
                                      .withValues(alpha: 0.35),
                                ),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected =
                                      item.trim() == initialValue.trim();
                                  return ListTile(
                                    title: Text(
                                      item,
                                      style:
                                          TextStyle(color: theme.canvasColor),
                                    ),
                                    trailing: isSelected
                                        ? Icon(Icons.check,
                                            color: theme.primaryColor)
                                        : null,
                                    onTap: () =>
                                        Navigator.pop(dialogContext, item),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    searchController.dispose();
    return selected;
  }

  Widget _buildReportFilters(GraphProvider provider, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = width > 1100
            ? (width - 48) / 4
            : width > 700
                ? (width - 24) / 2
                : width;

        final dateLabel = _reportDateRange == null
            ? "Select Date Range"
            : "${DateFormat('dd MMM yyyy').format(_reportDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_reportDateRange!.end)}";

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: itemWidth,
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: theme.cardColor,
                ),
                child: DropdownButtonFormField<String>(
                  value: _reportContentType,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.canvasColor),
                  decoration: InputDecoration(
                    labelText: "Content Type",
                    labelStyle: TextStyle(
                      color: theme.primaryColor.withValues(alpha: 0.75),
                    ),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  items: _contentTypeOptions
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(color: theme.canvasColor),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _reportContentType = value);
                  },
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () async {
                  final selected = await _showSearchableSelectionDialog(
                    context: context,
                    title: "Select Country",
                    options: provider.countryOptions,
                    initialValue: _reportCountry,
                    theme: theme,
                  );
                  if (selected == null) return;
                  final country = selected.trim();
                  setState(() {
                    _reportCountry = country;
                    _reportState = '';
                    _districtController.clear();
                    _talukaController.clear();
                    _cityController.clear();
                  });
                  if (country.isEmpty) {
                    provider.clearStateOptions();
                    return;
                  }
                  await provider.fetchStatesByCountry(country);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Country",
                    labelStyle: TextStyle(
                      color: theme.primaryColor.withValues(alpha: 0.75),
                    ),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.55),
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.search,
                      color: theme.primaryColor.withValues(alpha: 0.85),
                    ),
                  ),
                  child: Text(
                    _reportCountry.isEmpty ? "Search country" : _reportCountry,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: _reportCountry.isEmpty
                    ? null
                    : () async {
                        final selected = await _showSearchableSelectionDialog(
                          context: context,
                          title: "Select State",
                          options: provider.stateOptions,
                          initialValue: _reportState,
                          theme: theme,
                        );
                        if (selected == null) return;
                        setState(() {
                          _reportState = selected.trim();
                          _districtController.clear();
                          _talukaController.clear();
                          _cityController.clear();
                        });
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "State",
                    labelStyle: TextStyle(
                      color: theme.primaryColor.withValues(alpha: 0.75),
                    ),
                    border: const OutlineInputBorder(),
                    enabled: _reportCountry.isNotEmpty,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.55),
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.search,
                      color: theme.primaryColor.withValues(alpha: 0.85),
                    ),
                  ),
                  child: Text(
                    _reportState.isEmpty ? "Search state" : _reportState,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: TextField(
                controller: _districtController,
                enabled: _reportState.isNotEmpty,
                decoration: const InputDecoration(
                  labelText: "District",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {
                    _talukaController.clear();
                    _cityController.clear();
                  });
                },
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: TextField(
                controller: _talukaController,
                enabled: _districtController.text.trim().isNotEmpty,
                decoration: const InputDecoration(
                  labelText: "Taluka",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {
                    _cityController.clear();
                  });
                },
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: TextField(
                controller: _cityController,
                enabled: _talukaController.text.trim().isNotEmpty,
                decoration: const InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: OutlinedButton.icon(
                onPressed: _pickReportDateRange,
                icon: const Icon(Icons.date_range),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dateLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  side: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: ElevatedButton.icon(
                onPressed: () async => _applyReportFilters(),
                icon: const Icon(Icons.filter_alt),
                label: const Text("Apply Filters"),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: OutlinedButton.icon(
                onPressed: _clearReportFilters,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactReportList(
      List<ReportAndDataObject> movies, ThemeData selectedThemeData) {
    return Column(
      children: movies
          .map(
            (movie) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: selectedThemeData.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.movieName ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selectedThemeData.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Release: ${movie.releasedDate ?? '-'}"),
                    Text("Views: ${_formatNumber(_toInt(movie.views))}"),
                    Text("Revenue: ${_formatNumber(_toDouble(movie.revenue))}"),
                    Text("Commission: ${movie.percentageMediaHouse ?? 0}%"),
                    Text(
                        "Net Revenue: ${_formatNumber(_toInt(movie.netRevenue))}"),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: movie.views == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailsPage(
                                      movieId: movie.views!,
                                    ),
                                  ),
                                );
                              },
                        child: const Text("Open"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: Consumer<GraphProvider>(
        builder: (context, provider, child) {
          final isCompact = MediaQuery.of(context).size.width < 820;
          final sortedMovies = getSortedMovies(provider);
          final totalViews = sortedMovies.fold<int>(
            0,
            (sum, movie) => sum + _toInt(movie.views),
          );
          final totalRevenue = sortedMovies.fold<double>(
            0,
            (sum, movie) => sum + _toDouble(movie.revenue),
          );
          final totalNetRevenue = sortedMovies.fold<int>(
            0,
            (sum, movie) => sum + _toInt(movie.netRevenue),
          );

          return RefreshIndicator(
            onRefresh: _initData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: selectedThemeData.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Monitor performance and revenue across all published content.",
                    style: TextStyle(
                      color:
                          selectedThemeData.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      final cardWidth = isWide
                          ? (constraints.maxWidth - 24) / 3
                          : constraints.maxWidth;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _buildSummaryCard(
                              title: "Total Content",
                              value: "${sortedMovies.length}",
                              icon: Icons.movie_creation_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildSummaryCard(
                              title: "Total Views",
                              value: _formatNumber(totalViews),
                              icon: Icons.visibility_outlined,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildSummaryCard(
                              title: "Total Revenue",
                              value: _formatNumber(totalRevenue),
                              icon: Icons.attach_money_rounded,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Performance Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: selectedThemeData.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: isCompact ? 290 : 360,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedThemeData.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: TopMoviesLineGraph(isRevenue: false),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Reports & Data",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: selectedThemeData.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: selectedThemeData.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildReportFilters(provider, selectedThemeData),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: selectedThemeData.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: provider.isLoadingReportData
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : sortedMovies.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    child: Text(
                                      "No report data found.",
                                      style: TextStyle(
                                        color: selectedThemeData.primaryColor
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                )
                              : isCompact
                                  ? _buildCompactReportList(
                                      sortedMovies, selectedThemeData)
                                  : _buildMovieTable(
                                      sortedMovies, selectedThemeData),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Net Revenue: ${_formatNumber(totalNetRevenue)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selectedThemeData.primaryColor,
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
}
