import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_house/app/config/routes/app_routes.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/settlementCards.dart';
import 'package:media_house/data/models/response/mediaHouseWeeklySettelement.dart';
import 'package:provider/provider.dart';

import '../../../provider/settelementProvider.dart';

class SettlementPage extends StatefulWidget {
  const SettlementPage({super.key});

  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  bool _isLoading = true; // Track loading state
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      final provider = Provider.of<SettelementProvider>(context, listen: false);
      await provider.fetchWeeklySettelementDataForCurrentMediaHouse();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      body: Consumer<SettelementProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            // Show loader while fetching data
            return Center(
                child: CircularProgressIndicator(
              color: selectedThemeData.primaryColor,
            ));
          }

          if (provider.weeklySettelement.isEmpty) {
            // Show message if data is null or empty
            return Center(
              child: Text(
                provider.errorMessage ?? 'No settlement data available.',
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettlementCard(),
                  const SizedBox(height: 26),
                  _settlementTable(
                    context,
                    selectedThemeData,
                    provider.weeklySettelement,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedThemeData.primaryColor,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
        child: Icon(Icons.message_rounded),
      ),
    );
  }

  List<DataColumn> _buildColumns(ThemeData selectedThemeData,
      List<WeeklySettelementData> weeklySettelement) {
    return [
      _buildSortableColumn(
        'Transaction ID',
        (d) => d['transactionId'],
        0,
        selectedThemeData,
      ),
      _buildSortableColumn(
        'Start Date',
        (d) => d['startDate'],
        1,
        selectedThemeData,
      ),
      _buildSortableColumn(
        'End Date',
        (d) => d['endDate'],
        2,
        selectedThemeData,
      ),
      _buildSortableColumn(
          'Gross Revenue', (d) => d['GrossRevenue'], 3, selectedThemeData,
          numeric: true),
      _buildSortableColumn(
          'Tax Deduction', (d) => d['TaxDeduction'], 4, selectedThemeData,
          numeric: true),
      _buildSortableColumn(
          'Net Revenue', (d) => d['NetRevenue'], 5, selectedThemeData,
          numeric: true),
      _buildSortableColumn('OTT Share', (d) => d['OTTPlatformRevenueShare'], 6,
          selectedThemeData,
          numeric: true),
      _buildSortableColumn('Production House Share',
          (d) => d['MediaHouseRevenueShare'], 7, selectedThemeData,
          numeric: true),
    ];
  }

  Widget _settlementTable(
    BuildContext context,
    ThemeData selectedThemeData,
    List<WeeklySettelementData> weeklySettelement,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: selectedThemeData.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selectedThemeData.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1120),
          child: Theme(
            data: Theme.of(context).copyWith(
              cardColor: selectedThemeData.cardColor,
              dividerColor:
                  selectedThemeData.dividerColor.withValues(alpha: 0.28),
            ),
            child: DataTableTheme(
              data: DataTableThemeData(
                headingRowColor: WidgetStateProperty.all(
                  selectedThemeData.primaryColor.withValues(alpha: 0.08),
                ),
                dataRowColor: WidgetStateProperty.all(
                  selectedThemeData.cardColor,
                ),
                headingTextStyle: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
                dataTextStyle: TextStyle(
                  color: selectedThemeData.canvasColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: DataTable(
                columns: _buildColumns(
                  selectedThemeData,
                  weeklySettelement,
                ),
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                showCheckboxColumn: false,
                rows: weeklySettelement.map((settlement) {
                  final startDate = _formatEpoch(settlement.startDate);
                  final endDate = _formatEpoch(settlement.endDate);
                  return DataRow(cells: [
                    DataCell(Text(settlement.transactionId?.toString() ?? 'N/A')),
                    DataCell(Text(startDate)),
                    DataCell(Text(endDate)),
                    DataCell(Text('\$${_formatAmount(settlement.grossRevenue)}')),
                    DataCell(Text('\$${_formatAmount(settlement.taxDeduction)}')),
                    DataCell(Text('\$${_formatAmount(settlement.netRevenue)}')),
                    DataCell(Text(
                        '\$${_formatAmount(settlement.ottPlatformRevenueShare)}')),
                    DataCell(Text(
                        '\$${_formatAmount(settlement.mediaHouseRevenueShare)}')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(dynamic value) {
    if (value == null) return 'N/A';
    if (value is int) return value.toString();
    if (value is double) {
      final fixed = value.toStringAsFixed(2);
      return fixed.endsWith('.00') ? value.toInt().toString() : fixed;
    }
    return value.toString();
  }

  String _formatEpoch(int? value) {
    if (value == null) return 'N/A';
    return DateFormat('dd-MM-yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(value));
  }

  DataColumn _buildSortableColumn(
      String title,
      Comparable Function(Map<String, dynamic>) getField,
      int index,
      ThemeData selectedThemeData,
      {bool numeric = false}) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selectedThemeData.primaryColor,
        ),
      ),
      numeric: numeric,
      onSort: (columnIndex, ascending) =>
          _sort(getField, columnIndex, ascending),
    );
  }
}
