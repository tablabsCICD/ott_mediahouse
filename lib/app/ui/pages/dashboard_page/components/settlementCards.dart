import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../provider/settelementProvider.dart';
import 'package:intl/intl.dart';

import '../../../../provider/themeProvider.dart';

class SettlementCard extends StatefulWidget {
  const SettlementCard({super.key});

  @override
  State<SettlementCard> createState() => _SettlementCardState();
}

class _SettlementCardState extends State<SettlementCard> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
    _updateFilteredSettlements();
    searchController.addListener(_updateFilteredSettlements);
  }

  @override
  void dispose() {
    searchController.removeListener(_updateFilteredSettlements);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await Provider.of<SettelementProvider>(context, listen: false)
        .fetchWeeklySettelementDataForCurrentMediaHouse();
  }

  void _updateFilteredSettlements() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Consumer<SettelementProvider>(builder: (context, provider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(selectedThemeData),
          const SizedBox(height: 16),
          provider.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : provider.filleterdWeeklySettelement.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 70,
                          ),
                          Text(
                            provider.errorMessage ??
                                "No settlement data available",
                            style: TextStyle(
                                color: selectedThemeData.primaryColor),
                          ),
                        ],
                      ),
                    )
                  : _buildSettlementList(provider, selectedThemeData),
        ],
      );
    });
  }

  Widget _buildSearchBar(ThemeData selectedThemeData) {
    return ResponsiveWidget.isMobile(context)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(selectedThemeData),
              const SizedBox(height: 12),
              _searchField(selectedThemeData),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(selectedThemeData),
              SizedBox(width: 400, child: _searchField(selectedThemeData)),
            ],
          );
  }

  Widget _sectionTitle(ThemeData theme) {
    return Text(
      'Weekly Settlement',
      style: TextStyle(
        color: theme.primaryColor,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    );
  }

  Widget _searchField(ThemeData theme) {
    return TextField(
      controller: searchController,
      style: TextStyle(color: theme.canvasColor),
      decoration: InputDecoration(
        hintText: 'Search by dates, transaction ID ...',
        hintStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.55)),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }

  List<WeeklySettelementData> _filteredList(SettelementProvider provider) {
    final query = searchController.text.trim().toLowerCase();
    final list = provider.filleterdWeeklySettelement;
    if (query.isEmpty) return list;

    return list.where((item) {
      final haystack = [
        item.transactionId?.toString() ?? 'N/A',
        _formatEpoch(item.startDate),
        _formatEpoch(item.endDate),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  Widget _buildSettlementList(
    SettelementProvider provider,
    ThemeData theme,
  ) {
    final settlements = _filteredList(provider);
    if (settlements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No settlement records match your search.',
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: settlements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final data = settlements[index];
          return _buildSettlementCard(context, data);
        },
      ),
    );
  }

  Widget _buildSettlementCard(
      BuildContext context, WeeklySettelementData data) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    final startDate = _formatEpoch(data.startDate);
    final endDate = _formatEpoch(data.endDate);
    return SizedBox(
      width: 312,
      child: Material(
        color: selectedThemeData.cardColor,
        elevation: 0,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showDetailsDialog(context, data),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedThemeData.dividerColor.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Transaction ID: ${data.transactionId ?? 'N/A'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedThemeData.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedThemeData.primaryColor
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 13,
                            color: selectedThemeData.primaryColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'View',
                            style: TextStyle(
                              color: selectedThemeData.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$startDate - $endDate",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedThemeData.canvasColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _metricTile(
                        selectedThemeData,
                        'Revenue',
                        _parseNumber(data.grossRevenue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _metricTile(
                        selectedThemeData,
                        'Purchases',
                        _parseNumber(data.totalPurchases),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _metricTile(
                        selectedThemeData,
                        'Movies',
                        _parseNumber(data.totalUniqueMoviesSold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricTile(ThemeData theme, String label, String value) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, WeeklySettelementData data) {
    final startDate = _formatEpoch(data.startDate);
    final endDate = _formatEpoch(data.endDate);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 560),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              color: selectedThemeData.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Detailed Transaction",
                  style: TextStyle(
                    color: selectedThemeData.canvasColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Transaction ID: ${data.transactionId ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: selectedThemeData.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "From: $startDate - To: $endDate",
                  style: TextStyle(
                    color: selectedThemeData.canvasColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _dialogDivider(selectedThemeData),
                _buildDetailRow(
                  'Gross Revenue',
                  _parseNumber(data.grossRevenue),
                  selectedThemeData,
                ),
                _buildDetailRow(
                  'Tax Deduction',
                  _parseNumber(data.taxDeduction),
                  selectedThemeData,
                ),
                _buildDetailRow(
                  'Net Revenue',
                  _parseNumber(data.netRevenue),
                  selectedThemeData,
                ),
                _dialogDivider(selectedThemeData),
                _buildDetailRow(
                  'OTT Platform Share %',
                  _parseNumber(data.ottPlatformSharePercentage),
                  selectedThemeData,
                ),
                _buildDetailRow(
                  'OTT Platform Revenue Share',
                  _parseNumber(data.ottPlatformRevenueShare),
                  selectedThemeData,
                ),
                _dialogDivider(selectedThemeData),
                _buildDetailRow(
                  'Production House Share %',
                  _parseNumber(data.mediaHouseSharePercentage),
                  selectedThemeData,
                ),
                _buildDetailRow(
                  'Production House Revenue Share',
                  _parseNumber(data.mediaHouseRevenueShare),
                  selectedThemeData,
                ),
                _dialogDivider(selectedThemeData),
                Center(
                  child: Text(
                    "Movies Sold",
                    style: TextStyle(
                      color: selectedThemeData.canvasColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _getMoviesSoldList(data, selectedThemeData),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "PDF",
                        style:
                            TextStyle(color: selectedThemeData.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style:
                            TextStyle(color: selectedThemeData.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: theme.canvasColor.withValues(alpha: 0.16),
      ),
    );
  }

  List<Widget> _getMoviesSoldList(
    WeeklySettelementData data,
    ThemeData theme,
  ) {
    ListOfMoviesSold? moviesSold = data.listOfMoviesSold;
    if (moviesSold == null || moviesSold.entries.isEmpty) {
      return [
        Text(
          "No movie data available",
          style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.7)),
        ),
      ];
    }

    return moviesSold.entries.entries.map((entry) {
      return _buildDetailRow(
        entry.key,
        _parseNumber(entry.value),
        theme,
      );
    }).toList();
  }

  Widget _buildDetailRow(String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _parseNumber(dynamic value) {
    if (value is int) return value.toString();
    if (value is double) {
      final fixed = value.toStringAsFixed(2);
      return fixed.endsWith('.00') ? value.toInt().toString() : fixed;
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) return 'N/A';
      final fixed = parsed.toStringAsFixed(2);
      return fixed.endsWith('.00') ? parsed.toInt().toString() : fixed;
    }
    return 'N/A';
  }

  String _formatEpoch(int? value) {
    if (value == null) return 'N/A';
    return DateFormat('dd-MM-yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(value));
  }
}
