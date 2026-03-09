import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_house/app/config/routes/app_routes.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/settlementCards.dart';
import 'package:media_house/data/models/response/mediaHouseWeeklySettelement.dart';
import 'package:media_house/domain/entities/user.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/sharepreferences.dart';
import '../../../provider/settelementProvider.dart';

class SettlementPage extends StatefulWidget {
  @override
  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  SettlementDataSource? _settlementDataSource; // Make this nullable
  bool _isLoading = true; // Track loading state
  int _rowsPerPage = 10;
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
      final localSharePreferences = LocalSharePreferences();
      User? user = await localSharePreferences.getUser();
      if (user != null) {
        await Provider.of<SettelementProvider>(context, listen: false)
            .fetchWeeklySettelementDataByMediaHouseId(user.id!);
        final settlements =
            Provider.of<SettelementProvider>(context, listen: false)
                .weeklySettelement;
        if (settlements != null && settlements.isNotEmpty) {
          _settlementDataSource = SettlementDataSource(settlements);
        }
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _settlementDataSource!.sort(getField, ascending);
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

          if (provider.weeklySettelement == null ||
              provider.weeklySettelement.isEmpty) {
            // Show message if data is null or empty
            return Center(
              child: Text(
                'No settlement data available.',
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          // Check if _settlementDataSource is initialized
          if (_settlementDataSource == null) {
            return Center(
              child: Text(
                'An error occurred while loading settlement data.',
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SettlementCard(),
                SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: DataTableTheme(
                        data: DataTableThemeData(
                          headingRowColor: WidgetStateProperty.all(
                            selectedThemeData.cardColor,
                          ),
                          dataRowColor: WidgetStateProperty.all(
                            selectedThemeData.cardColor,
                          ),
                        ),
                        child: PaginatedDataTable(
                          header: Text(
                            'Settlement Records',
                            style: TextStyle(
                              color: selectedThemeData.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          columns: _buildColumns(
                            selectedThemeData,
                            provider.weeklySettelement,
                          ),
                          source: _settlementDataSource!,
                          rowsPerPage: _rowsPerPage,
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          showCheckboxColumn: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
      _buildSortableColumn(
          'Total Purchases', (d) => d['TotalPurchases'], 8, selectedThemeData,
          numeric: true),
      _buildSortableColumn(
        'Most Purchased Movie',
        (d) => d['MostPurchasedMovie'],
        9,
        selectedThemeData,
      ),
    ];
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

class SettlementDataSource extends DataTableSource {
  List<WeeklySettelementData> _settlements;
  List<WeeklySettelementData> _sortedSettlements;

  SettlementDataSource(this._settlements)
      : _sortedSettlements = List.from(_settlements);

  void sort<T>(
      Comparable<T> Function(Map<String, dynamic>) getField, bool ascending) {
    /* _sortedSettlements.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });*/
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final settlement = _sortedSettlements[index];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(settlement.startDate!);
    String? startDate = DateFormat('dd-MM-yyyy').format(date);
    DateTime date1 = DateTime.fromMillisecondsSinceEpoch(settlement.endDate!);
    String? endDate = DateFormat('dd-MM-yyyy').format(date1);
    return DataRow(cells: [
      DataCell(Text(settlement.transactionId ?? 'N/A')),
      DataCell(Text(startDate.toString())),
      DataCell(Text(endDate.toString())),
      DataCell(Text('\$${settlement.grossRevenue ?? 'N/A'}')),
      DataCell(Text('\$${settlement.taxDeduction ?? 'N/A'}')),
      DataCell(Text('\$${settlement.netRevenue ?? 'N/A'}')),
      DataCell(Text('\$${settlement.ottPlatformRevenueShare ?? 'N/A'}')),
      DataCell(Text('\$${settlement.mediaHouseSharePercentage ?? 'N/A'}')),
      DataCell(Text('${settlement.totalPurchases ?? 'N/A'}')),
      DataCell(Text(settlement.mostPurchasedMovie ?? 'N/A')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _sortedSettlements.length;
  @override
  int get selectedRowCount => 0;
}
