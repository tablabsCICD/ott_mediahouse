import 'package:flutter/material.dart';
import 'package:media_house/app/config/routes/app_routes.dart';
import 'package:media_house/app/provider/settelementProvider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/settlementCards.dart';
import 'package:media_house/data/models/response/media_house_settlement.dart';
import 'package:provider/provider.dart';

class SettlementPage extends StatefulWidget {
  const SettlementPage({super.key});
  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SettelementProvider>()
          .fetchForCurrentMediaHouse(page: 0, size: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final provider = context.watch<SettelementProvider>();
    return Scaffold(
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : provider.errorMessage != null
              ? _error(provider, theme)
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettlementCard(
                            autoLoad: false,
                            onSearchChanged: (value) =>
                                setState(() => _query = value)),
                        if (provider.settlements.isNotEmpty) ...[
                          const SizedBox(height: 26),
                          _table(theme, _filtered(provider.settlements)),
                          const SizedBox(height: 16),
                          _pagination(provider, theme),
                        ],
                      ]),
                )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
        child: const Icon(Icons.message_rounded),
      ),
    );
  }

  List<MediaHouseSettlement> _filtered(List<MediaHouseSettlement> list) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list
        .where((item) => [
              item.settlementId ?? 'N/A',
              item.settlementStatusValue,
              item.contentTypeValue,
              item.mediaHouseName,
              formatSettlementDate(item.periodStartDate),
              formatSettlementDate(item.periodEndDate),
              formatSettlementDate(item.settlementDate, includeTime: true),
            ].join(' ').toLowerCase().contains(query))
        .toList(growable: false);
  }

  Widget _error(SettelementProvider provider, ThemeData theme) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, color: theme.primaryColor, size: 42),
            const SizedBox(height: 12),
            Text(provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.canvasColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
                onPressed: provider.retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry')),
          ]),
        ),
      );

  Widget _table(ThemeData theme, List<MediaHouseSettlement> rows) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: theme.dividerColor.withValues(alpha: .3))),
        child: rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                    child: Text('No settlement records match your search.',
                        style: TextStyle(color: theme.canvasColor))))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                      theme.primaryColor.withValues(alpha: .08)),
                  headingTextStyle: TextStyle(
                      color: theme.primaryColor, fontWeight: FontWeight.w800),
                  dataTextStyle: TextStyle(
                      color: theme.canvasColor, fontWeight: FontWeight.w600),
                  columns: const [
                    DataColumn(label: Text('Settlement ID')),
                    DataColumn(label: Text('Start Date')),
                    DataColumn(label: Text('End Date')),
                    DataColumn(label: Text('Settlement Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Transactions'), numeric: true),
                    DataColumn(label: Text('Content Type')),
                    DataColumn(label: Text('Customer Payment'), numeric: true),
                    DataColumn(label: Text('GST Charges'), numeric: true),
                    DataColumn(label: Text('Platform Charges'), numeric: true),
                    DataColumn(label: Text('Net Revenue'), numeric: true),
                    DataColumn(label: Text('Commission %'), numeric: true),
                    DataColumn(
                        label: Text('Media House Commission'), numeric: true),
                    DataColumn(label: Text('Gross Revenue'), numeric: true),
                    DataColumn(label: Text('TDS'), numeric: true),
                    DataColumn(
                        label: Text('Settlement Charges'), numeric: true),
                    DataColumn(label: Text('Other Deductions'), numeric: true),
                    DataColumn(label: Text('Total Deductions'), numeric: true),
                    DataColumn(
                        label: Text('Final Payable Amount'), numeric: true),
                  ],
                  rows: rows
                      .map((item) => DataRow(
                              onSelectChanged: (_) =>
                                  openSettlementReport(context, item),
                              cells: [
                                DataCell(Text(item.settlementId ?? 'N/A')),
                                DataCell(Text(formatSettlementDate(
                                    item.periodStartDate))),
                                DataCell(Text(
                                    formatSettlementDate(item.periodEndDate))),
                                DataCell(Text(formatSettlementDate(
                                    item.settlementDate,
                                    includeTime: true))),
                                DataCell(Text(item.settlementStatusValue)),
                                DataCell(Text('${item.totalTransactions}')),
                                DataCell(Text(item.contentTypeValue)),
                                DataCell(
                                    Text(formatCurrency(item.customerPayment))),
                                DataCell(Text(formatCurrency(item.gstCharges))),
                                DataCell(Text(formatCurrency(
                                    item.customerPlatformCharges))),
                                DataCell(Text(formatCurrency(item.netRevenue))),
                                DataCell(Text(formatPercentage(
                                    item.mediaHouseCommissionPercentage))),
                                DataCell(Text(
                                    formatCurrency(item.mediaHouseCommission))),
                                DataCell(Text(formatCurrency(item.grossRevenue))),
                                DataCell(Text(formatCurrency(item.tds))),
                                DataCell(Text(formatCurrency(
                                    item.settlementPlatformCharges))),
                                DataCell(
                                    Text(formatCurrency(item.otherDeductions))),
                                DataCell(
                                    Text(formatCurrency(item.totalDeductions))),
                                DataCell(Text(
                                    formatCurrency(item.finalPayableAmount))),
                              ]))
                      .toList(),
                )),
      );

  Widget _pagination(SettelementProvider provider, ThemeData theme) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${provider.totalElements} records',
              style: TextStyle(color: theme.canvasColor.withValues(alpha: .7))),
          const SizedBox(width: 16),
          DropdownButton<int>(
              value: provider.pageSize,
              dropdownColor: theme.cardColor,
              items: const [10, 20, 50, 100]
                  .map((size) => DropdownMenuItem(
                      value: size, child: Text('$size / page')))
                  .toList(),
              onChanged: (size) {
                if (size != null) provider.changePageSize(size);
              }),
          const SizedBox(width: 12),
          if (provider.isLoadingMore)
            const SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            ElevatedButton.icon(
              onPressed: provider.last ? null : provider.loadMore,
              icon: const Icon(Icons.expand_more),
              label: Text(provider.last ? 'All records loaded' : 'Load more'),
            ),
        ],
      );
}
