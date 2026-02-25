import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_house/app/provider/graphProvider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TopMoviesLineGraph extends StatefulWidget {
  final bool isRevenue;

  const TopMoviesLineGraph({super.key, required this.isRevenue});

  @override
  State<TopMoviesLineGraph> createState() => _TopMoviesLineGraphState();
}

class _TopMoviesLineGraphState extends State<TopMoviesLineGraph> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getData();
      _syncControllersWithProvider();
    });
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _getData() async {
    final provider = Provider.of<GraphProvider>(context, listen: false);
    if (widget.isRevenue) {
      await provider.fetchTopPerformingMovieGraph(0);
      return;
    }
    await provider.fetchTopRatedMovieGraph(0);
  }

  void _syncControllersWithProvider() {
    final provider = Provider.of<GraphProvider>(context, listen: false);
    _countryController.text = provider.countryFilter;
    _stateController.text = provider.stateFilter;
    _districtController.text = provider.districtFilter;
    _talukaController.text = provider.talukaFilter;
    _cityController.text = provider.cityFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<GraphProvider>(
      builder: (context, provider, child) {
        final isMobile = ResponsiveWidget.isMobile(context);
        return Column(
          children: [
            _buildHeader(theme, provider, isMobile),
            const SizedBox(height: 10),
            _buildCompactFilterBar(theme, provider, isMobile),
            const SizedBox(height: 8),
            _buildActiveFilterChips(theme, provider),
            const SizedBox(height: 8),
            Expanded(child: _buildChart(theme, provider)),
            const SizedBox(height: 8),
            _buildDateButtons(theme, provider, isMobile),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, GraphProvider provider, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isRevenue ? 'Top Performing Content' : 'Top Rated Content',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.selectedDateRange == null
                ? "Select Date Range"
                : "${DateFormat.yMMMd().format(provider.selectedDateRange!.start)} - ${DateFormat.yMMMd().format(provider.selectedDateRange!.end)}",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.canvasColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          widget.isRevenue ? 'Top Performing Movies' : 'Top Rated Movies',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          provider.selectedDateRange == null
              ? "Select Date Range"
              : "${DateFormat.yMMMd().format(provider.selectedDateRange!.start)} - ${DateFormat.yMMMd().format(provider.selectedDateRange!.end)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.canvasColor.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFilterBar(
      ThemeData theme, GraphProvider provider, bool isMobile) {
    final labelColor = theme.canvasColor.withValues(alpha: 0.8);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 8 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            theme.canvasColor.withValues(alpha: 0.08),
            theme.canvasColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownFilter(
              theme,
              width: 0,
              label: "Type",
              value: provider.selectedContentType,
              items: const ["ALL", "MOVIE", "SERIES", "SHORTS"],
              onChanged: (value) {
                provider.setContentTypeFilter(value ?? "ALL");
              },
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showAdvancedFiltersDialog(theme, provider),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text("More"),
            style: OutlinedButton.styleFrom(
              foregroundColor: labelColor,
              side: BorderSide(color: theme.dividerColor),
              minimumSize: Size(isMobile ? 80 : 96, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => provider.applyTopMoviesFilters(widget.isRevenue),
            style: IconButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.search_rounded, size: 18),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () {
              provider.clearTopMoviesFilters();
              _syncControllersWithProvider();
              provider.applyTopMoviesFilters(widget.isRevenue);
            },
            style: IconButton.styleFrom(
              foregroundColor: labelColor,
              side: BorderSide(color: theme.dividerColor),
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(ThemeData theme, GraphProvider provider) {
    final chips = <String>[];
    if (provider.selectedContentType.toUpperCase() != "ALL") {
      chips.add("Type: ${provider.selectedContentType}");
    }
    if (provider.countryFilter.trim().isNotEmpty) {
      chips.add("Country: ${provider.countryFilter.trim()}");
    }
    if (provider.stateFilter.trim().isNotEmpty) {
      chips.add("State: ${provider.stateFilter.trim()}");
    }
    if (provider.districtFilter.trim().isNotEmpty) {
      chips.add("District: ${provider.districtFilter.trim()}");
    }
    if (provider.talukaFilter.trim().isNotEmpty) {
      chips.add("Taluka: ${provider.talukaFilter.trim()}");
    }
    if (provider.cityFilter.trim().isNotEmpty) {
      chips.add("City: ${provider.cityFilter.trim()}");
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: chips
            .map(
              (chip) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  chip,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> _showAdvancedFiltersDialog(
      ThemeData theme, GraphProvider provider) async {
    await provider.fetchCountriesIfNeeded();
    if (provider.countryFilter.trim().isNotEmpty &&
        provider.stateOptions.isEmpty) {
      await provider.fetchStatesByCountry(provider.countryFilter.trim());
    }
    if (!mounted) return;

    final districtCtrl = TextEditingController(text: _districtController.text);
    final talukaCtrl = TextEditingController(text: _talukaController.text);
    final cityCtrl = TextEditingController(text: _cityController.text);

    await showDialog<void>(
      context: context,
      builder: (_) {
        return Consumer<GraphProvider>(
          builder: (context, graphProvider, __) {
            final countryValue = graphProvider.countryFilter.trim().isEmpty
                ? null
                : graphProvider.countryFilter;
            final stateValue = graphProvider.stateFilter.trim().isEmpty
                ? null
                : graphProvider.stateFilter;
            return Dialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 900
                    ? 600 // desktop
                    : MediaQuery.of(context).size.width > 600
                        ? 500 // tablet
                        : MediaQuery.of(context).size.width * 0.9, //
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Location Wise Filters",
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: theme.canvasColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildSearchableSelectorField(
                        context: context,
                        theme: theme,
                        label: "Country",
                        value: countryValue,
                        isLoading: graphProvider.isLoadingCountries,
                        onTap: () async {
                          final selectedCountry = await _showSearchPickerDialog(
                            context: context,
                            theme: theme,
                            title: "Search Country",
                            options: graphProvider.countryOptions,
                            initialValue: graphProvider.countryFilter,
                          );
                          if (selectedCountry == null) return;
                          await graphProvider
                              .selectCountryAndLoadStates(selectedCountry);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildSearchableSelectorField(
                        context: context,
                        theme: theme,
                        label: "State",
                        value: stateValue,
                        isLoading: graphProvider.isLoadingStates,
                        enabled: graphProvider.countryFilter.trim().isNotEmpty,
                        onTap: () async {
                          final selectedState = await _showSearchPickerDialog(
                            context: context,
                            theme: theme,
                            title: "Search State",
                            options: graphProvider.stateOptions,
                            initialValue: graphProvider.stateFilter,
                          );
                          if (selectedState == null) return;
                          graphProvider.setStateFilter(selectedState);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        theme,
                        "District",
                        districtCtrl,
                        enabled: graphProvider.stateFilter.trim().isNotEmpty,
                        onChanged: (_) => setState(() {}), // 🔥 ADD THIS
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        theme,
                        "Taluka",
                        talukaCtrl,
                        enabled: districtCtrl.text.trim().isNotEmpty,
                        onChanged: (_) => setState(() {}), // 🔥 ADD THIS
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        theme,
                        "City",
                        _cityController,
                        enabled: talukaCtrl.text.trim().isNotEmpty,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (graphProvider.countryFilter
                                    .trim()
                                    .isEmpty) {
                                  _showError("Please select Country");
                                  return;
                                }
                                if (graphProvider.stateFilter.trim().isEmpty) {
                                  _showError("Please select State");
                                  return;
                                }
                                if (districtCtrl.text.trim().isEmpty) {
                                  _showError("Please enter District");
                                  return;
                                }
                                if (talukaCtrl.text.trim().isEmpty) {
                                  _showError("Please enter Taluka");
                                  return;
                                }
                                if (_cityController.text.trim().isEmpty) {
                                  _showError("Please enter City");
                                  return;
                                }

                                _countryController.text =
                                    graphProvider.countryFilter.trim();
                                _stateController.text =
                                    graphProvider.stateFilter.trim();
                                _districtController.text =
                                    districtCtrl.text.trim();
                                _talukaController.text = talukaCtrl.text.trim();
                                _cityController.text = cityCtrl.text.trim();

                                graphProvider.setDistrictFilter(
                                    _districtController.text);
                                graphProvider
                                    .setTalukaFilter(_talukaController.text);
                                graphProvider
                                    .setCityFilter(_cityController.text);

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Save"),
                            ),
                          ),
                        ],
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

    districtCtrl.dispose();
    talukaCtrl.dispose();
    cityCtrl.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildDialogTextField(
    ThemeData theme,
    String label,
    TextEditingController controller, {
    bool enabled = true,
    Function(String)? onChanged, // 👈 ADD
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged, // 👈 ADD
      style: TextStyle(
        color: enabled ? theme.canvasColor : Colors.grey,
      ),
      decoration: _filterInputDecoration(theme, label).copyWith(
        filled: true,
        fillColor: enabled ? null : Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildSearchableSelectorField({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required String? value,
    required VoidCallback onTap,
    bool enabled = true,
    bool isLoading = false,
  }) {
    final displayText = (value == null || value.trim().isEmpty)
        ? "Select $label"
        : value.trim();
    return InkWell(
      onTap: enabled && !isLoading ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _filterInputDecoration(theme, label).copyWith(
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search_rounded, size: 18),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: enabled
                ? theme.canvasColor
                : theme.canvasColor.withValues(alpha: 0.4),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<String?> _showSearchPickerDialog({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required List<String> options,
    String initialValue = '',
  }) async {
    final searchController = TextEditingController(text: initialValue);
    List<String> filtered = List<String>.from(options);

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void applyFilter(String query) {
              final q = query.trim().toLowerCase();
              setState(() {
                filtered = options
                    .where((item) => item.toLowerCase().contains(q))
                    .toList(growable: false);
              });
            }

            return Dialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox(
                width: 420,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: searchController,
                        onChanged: applyFilter,
                        style: TextStyle(color: theme.canvasColor),
                        decoration:
                            _filterInputDecoration(theme, "Search").copyWith(
                          prefixIcon:
                              const Icon(Icons.search_rounded, size: 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Text(
                                    "No results found",
                                    style: TextStyle(
                                      color: theme.canvasColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: theme.dividerColor
                                      .withValues(alpha: 0.35),
                                ),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(item),
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
  }

  Widget _buildDropdownFilter(
    ThemeData theme, {
    required double width,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return width > 0
        ? SizedBox(
            width: width,
            child: DropdownButtonFormField<String>(
              initialValue: value,
              decoration: _filterInputDecoration(theme, label),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(growable: false),
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: theme.cardColor,
            ),
          )
        : DropdownButtonFormField<String>(
            initialValue: value,
            decoration: _filterInputDecoration(theme, label),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(growable: false),
            onChanged: onChanged,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: theme.cardColor,
          );
  }

  InputDecoration _filterInputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.2),
      ),
    );
  }

  Widget _buildChart(ThemeData theme, GraphProvider provider) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.78)),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.78)),
      ),
      plotAreaBorderWidth: 0,
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: provider.graphData,
          xValueMapper: (movie, _) => movie['label'],
          yValueMapper: (movie, _) => movie['value'],
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: theme.primaryColor,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: theme.primaryColor,
            borderColor: theme.primaryColor,
          ),
          width: 2.3,
        ),
      ],
    );
  }

  Widget _buildDateButtons(
      ThemeData theme, GraphProvider provider, bool isMobile) {
    final ranges = const [
      {'label': 'Week', 'days': 7},
      {'label': 'Month', 'days': 30},
      {'label': 'Year', 'days': 365},
      {'label': 'Custom Dates', 'days': 0},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: ranges
          .map(
            (range) => _buildDateButton(
              theme,
              provider,
              label: range['label']! as String,
              days: range['days']! as int,
              isCustom: range['label'] == 'Custom Dates',
              compact: isMobile,
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildDateButton(
    ThemeData theme,
    GraphProvider provider, {
    required String label,
    required int days,
    required bool isCustom,
    required bool compact,
  }) {
    final isActive = provider.activeButton == label;
    return InkWell(
      onTap: isCustom
          ? () => provider.pickDateRange(context, widget.isRevenue)
          : () => provider.setDateRange(label, days, context, widget.isRevenue),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? theme.primaryColor
              : theme.canvasColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : theme.canvasColor,
            fontWeight: FontWeight.w600,
            fontSize: compact ? 12 : 14,
          ),
        ),
      ),
    );
  }
}
