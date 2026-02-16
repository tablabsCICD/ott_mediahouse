import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_house/app/provider/graphProvider.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/MovieDetailsPage.dart';
import 'package:media_house/app/widget/TopMoviesLineGraph.dart';
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
            ? _toDouble(a.totalRevenue).compareTo(_toDouble(b.totalRevenue))
            : _toDouble(b.totalRevenue).compareTo(_toDouble(a.totalRevenue));
      } else {
        return _isAscending
            ? (a.contentName ?? '').compareTo(b.contentName ?? '')
            : (b.contentName ?? '').compareTo(a.contentName ?? '');
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
                    color: selectedThemeData.primaryColor.withValues(alpha: 0.75),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                      DataCell(Text(movie.contentName ?? '-')),
                      DataCell(Text("${movie.releasedDate ?? '-'}")),
                      DataCell(Text(_formatNumber(_toInt(movie.totalViews)))),
                      DataCell(Text(_formatNumber(_toDouble(movie.totalRevenue)))),
                      DataCell(Text("${movie.currentPecentageIncentive ?? 0}%")),
                      DataCell(Text(_formatNumber(_toInt(movie.earnedIncentive)))),
                      DataCell(
                        TextButton(
                          onPressed: movie.contentId == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailsPage(
                                        movieId: movie.contentId!,
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
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Provider.of<GraphProvider>(context, listen: false)
        .getReportAndData(context);
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: Consumer<GraphProvider>(
        builder: (context, provider, child) {
          final sortedMovies = getSortedMovies(provider);
          final totalViews = sortedMovies.fold<int>(
            0,
            (sum, movie) => sum + _toInt(movie.totalViews),
          );
          final totalRevenue = sortedMovies.fold<double>(
            0,
            (sum, movie) => sum + _toDouble(movie.totalRevenue),
          );
          final totalNetRevenue = sortedMovies.fold<int>(
            0,
            (sum, movie) => sum + _toInt(movie.earnedIncentive),
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
                      color: selectedThemeData.primaryColor.withValues(alpha: 0.7),
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
                    height: 360,
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
                      padding: const EdgeInsets.all(16),
                      child: sortedMovies.isEmpty
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  "No report data found.",
                                  style: TextStyle(
                                    color: selectedThemeData.primaryColor
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            )
                          : _buildMovieTable(sortedMovies, selectedThemeData),
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
