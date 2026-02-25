import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../provider/mediaHouseProvider.dart';
import '../provider/themeProvider.dart';

class CustomLineGraph extends StatefulWidget {
  final String title;
  final String yAxisLabel;
  final int graphNumber;

  final List<String> metrics; // e.g. ["revenue", "users_onboarded"]
  final bool canPop;

  const CustomLineGraph({
    super.key,
    required this.title,
    required this.yAxisLabel,
    required this.metrics,
    this.canPop = false,
    required this.graphNumber,
  });

  @override
  _CustomLineGraphState createState() => _CustomLineGraphState();
}

class _CustomLineGraphState extends State<CustomLineGraph> {
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  DateTimeRange? selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 7)),
    end: DateTime.now(),
  );
  DateTime get today => DateTime.now();
  DateTime? startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime? endDate = DateTime.now();
  String activeButton = '1W';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<MediaHouseProvider>(context, listen: false);
      _districtController.text = provider.customGraphDistrict;
      _talukaController.text = provider.customGraphTaluka;
      _cityController.text = provider.customGraphCity;
      _fetchGraphData(
          0, DateTime.now().subtract(Duration(days: 7)), DateTime.now());
    });
  }

  @override
  void dispose() {
    _districtController.dispose();
    _talukaController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDialog<DateTimeRange>(
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
              lastDate: today,
              initialDateRange: selectedDateRange,
              helpText: 'Select Custom Date Range',
              confirmText: 'Apply',
              cancelText: 'Cancel',
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    if (picked != null) {
      final previousButton = activeButton;
      selectedDateRange = picked;
      activeButton = 'Custom Dates';
      startDate = picked.start;
      endDate = picked.end;
      final selectedTimeRange = previousButton == '1M'
          ? 1
          : previousButton == '1Y'
              ? 2
              : 0;
      await _fetchGraphData(selectedTimeRange, startDate!, endDate!);
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _setDateRange(String label, int days) async {
    int selectedTimeRange;
    if (label == '1W') {
      selectedTimeRange = 0;
    } else if (label == '1M') {
      selectedTimeRange = 1;
    } else {
      selectedTimeRange = 2;
    }

    final DateTime calculatedEndDate = DateTime.now();
    final DateTime calculatedStartDate =
        calculatedEndDate.subtract(Duration(days: days));

    // Fetch the graph data first
    await _fetchGraphData(
        selectedTimeRange, calculatedStartDate, calculatedEndDate);

    // Update the state after data is fetched
    setState(() {
      activeButton = label;
      startDate = calculatedStartDate;
      endDate = calculatedEndDate;
      selectedDateRange = DateTimeRange(start: startDate!, end: endDate!);
    });
  }

  Future<void> _fetchGraphData(
      int selectedTimeRange, DateTime startDate, DateTime endDate) async {
    final mediaHouseProvider =
        Provider.of<MediaHouseProvider>(context, listen: false);

    final startDateString = DateFormat("yyyy-MM-dd").format(startDate);
    final endDateString = DateFormat("yyyy-MM-dd").format(endDate);

    if (widget.graphNumber == 0) {
      await mediaHouseProvider.revenueGraphByMediaHouse(
        selectedTimeRange,
        startDateString,
        endDateString,
      );
    } else if (widget.graphNumber == 1) {
      await mediaHouseProvider.viewsCountGraph(
        selectedTimeRange,
        startDateString,
        endDateString,
      );
    } else if (widget.graphNumber == 2) {
      await mediaHouseProvider.releaseMovieCountGraph(
        selectedTimeRange,
        startDateString,
        endDateString,
      );
    } else if (widget.graphNumber == 3) {
      await mediaHouseProvider.revenueGraphByMediaHouse(
        selectedTimeRange,
        startDateString,
        endDateString,
      );
    } else {
      await mediaHouseProvider.revenueGraphByMediaHouse(
        selectedTimeRange,
        startDateString,
        endDateString,
      );
    }
  }

  Future<void> _applyCurrentFilters() async {
    if (startDate == null || endDate == null) return;
    int selectedTimeRange = 0;
    if (activeButton == '1M') {
      selectedTimeRange = 1;
    } else if (activeButton == '1Y') {
      selectedTimeRange = 2;
    }
    await _fetchGraphData(selectedTimeRange, startDate!, endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartHeight = constraints.maxHeight > 520 ? 300.0 : 220.0;
          return Column(
            children: [
              widget.canPop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_sharp,
                            color: selectedThemeData.canvasColor,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(height: 5),
              _buildTitle(selectedThemeData),
              const SizedBox(height: 10),
              _buildCompactFilterBar(selectedThemeData),
              const SizedBox(height: 10),
              SizedBox(
                height: chartHeight,
                child: _buildChart(selectedThemeData),
              ),
              const SizedBox(height: 10),
              _buildFilterOptions(selectedThemeData),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitle(ThemeData selectedThemeData) {
    return Text(
      widget.title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: selectedThemeData.primaryColor,
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          selectedDateRange == null
              ? "Select Date Range"
              : "${DateFormat.yMMMd().format(selectedDateRange!.start)} - ${DateFormat.yMMMd().format(selectedDateRange!.end)}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildChart(ThemeData selectedThemeData) {
    return Consumer<MediaHouseProvider>(
      builder: (context, provider, child) {
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(
            title: const AxisTitle(
              text: '<-------------- Time -------------->',
              textStyle: TextStyle(fontSize: 12),
            ),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            LineSeries<LineChartData, String>(
              dataSource: provider.graphData,
              xValueMapper: (LineChartData data, _) => data.label,
              yValueMapper: (LineChartData data, _) => data.value,
              color: selectedThemeData.primaryColor,
              markerSettings: MarkerSettings(
                isVisible: true,
                color: selectedThemeData.primaryColor,
                shape: DataMarkerType.circle,
              ),
              width: 3,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactFilterBar(ThemeData theme) {
    return Consumer<MediaHouseProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
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
              child: isNarrow
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: _buildTypeDropdown(provider, theme)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildDateSelection())
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildFilterActions(provider, theme, stacked: true),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildTypeDropdown(provider, theme)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDateSelection(),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterActions(provider, theme),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeDropdown(MediaHouseProvider provider, ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: provider.customGraphContentType,
      items: const ["ALL", "MOVIE", "SERIES", "SHORTS"]
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(growable: false),
      onChanged: (value) => provider.setCustomGraphContentType(value ?? "ALL"),
      decoration: _filterInputDecoration(theme, "Type"),
      dropdownColor: theme.cardColor,
    );
  }

  Widget _buildFilterActions(MediaHouseProvider provider, ThemeData theme,
      {bool stacked = false}) {
    final children = [
      OutlinedButton.icon(
        onPressed: () => _showAdvancedFiltersDialog(theme, provider),
        icon: const Icon(Icons.tune_rounded, size: 16),
        label: const Text("More"),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.dividerColor),
          foregroundColor: theme.canvasColor.withValues(alpha: 0.9),
          minimumSize: const Size(90, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(width: 8, height: 8),
      IconButton.filled(
        onPressed: _applyCurrentFilters,
        style: IconButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.search_rounded, size: 18),
      ),
      const SizedBox(width: 6, height: 6),
      IconButton(
        onPressed: () {
          provider.clearCustomGraphFilters();
          _districtController.clear();
          _talukaController.clear();
          _cityController.clear();
          _applyCurrentFilters();
        },
        style: IconButton.styleFrom(
          foregroundColor: theme.canvasColor.withValues(alpha: 0.9),
          side: BorderSide(color: theme.dividerColor),
        ),
        icon: const Icon(Icons.refresh_rounded, size: 18),
      ),
    ];

    if (stacked) {
      return Row(
        children: [
          Expanded(child: children[0]),
          children[1],
          children[2],
          children[3],
          children[4],
        ],
      );
    }
    return Row(children: children);
  }

  Future<void> _showAdvancedFiltersDialog(
      ThemeData theme, MediaHouseProvider provider) async {
    await provider.fetchCustomGraphCountriesIfNeeded();
    if (provider.customGraphCountry.trim().isNotEmpty &&
        provider.customGraphStateOptions.isEmpty) {
      await provider
          .fetchCustomGraphStatesByCountry(provider.customGraphCountry);
    }
    if (!mounted) return;

    final districtCtrl = TextEditingController(text: _districtController.text);
    final talukaCtrl = TextEditingController(text: _talukaController.text);

    await showDialog<void>(
      context: context,
      builder: (_) {
        return Consumer<MediaHouseProvider>(
          builder: (context, graphProvider, __) {
            final countryValue = graphProvider.customGraphCountry.trim().isEmpty
                ? null
                : graphProvider.customGraphCountry;
            final stateValue = graphProvider.customGraphState.trim().isEmpty
                ? null
                : graphProvider.customGraphState;
            return Dialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 900
                    ? 600 // desktop
                    : MediaQuery.of(context).size.width > 600
                        ? 500 // tablet
                        : MediaQuery.of(context).size.width * 0.9,
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
                        isLoading: graphProvider.isLoadingCustomGraphCountries,
                        onTap: () async {
                          final selectedCountry = await _showSearchPickerDialog(
                            context: context,
                            theme: theme,
                            title: "Search Country",
                            options: graphProvider.customGraphCountryOptions,
                            initialValue: graphProvider.customGraphCountry,
                          );
                          if (selectedCountry == null) return;
                          await graphProvider
                              .selectCustomGraphCountryAndLoadStates(
                                  selectedCountry);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildSearchableSelectorField(
                        context: context,
                        theme: theme,
                        label: "State",
                        value: stateValue,
                        isLoading: graphProvider.isLoadingCustomGraphStates,
                        enabled:
                            graphProvider.customGraphCountry.trim().isNotEmpty,
                        onTap: () async {
                          final selectedState = await _showSearchPickerDialog(
                            context: context,
                            theme: theme,
                            title: "Search State",
                            options: graphProvider.customGraphStateOptions,
                            initialValue: graphProvider.customGraphState,
                          );
                          if (selectedState == null) return;
                          graphProvider.setCustomGraphState(selectedState);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(theme, "District", districtCtrl,
                          enabled:
                              graphProvider.customGraphState.trim().isNotEmpty,
                          onChanged: (_) => setState(() {})),
                      const SizedBox(height: 8),
                      _buildDialogTextField(theme, "Taluka", talukaCtrl,
                          enabled: districtCtrl.text.trim().isNotEmpty,
                          onChanged: (_) => setState(() {})),
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
                                if (graphProvider.customGraphCountry
                                    .trim()
                                    .isEmpty) {
                                  _showError("Please select Country");
                                  return;
                                }
                                if (graphProvider.customGraphState
                                    .trim()
                                    .isEmpty) {
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

                                _districtController.text =
                                    districtCtrl.text.trim();
                                _talukaController.text = talukaCtrl.text.trim();

                                graphProvider.setCustomGraphDistrict(
                                    _districtController.text);
                                graphProvider.setCustomGraphTaluka(
                                    _talukaController.text);

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
    _cityController.dispose();
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

  Widget _buildFilterOptions(ThemeData selectedThemeData) {
    final filterOptions = [
      {'label': '1W', 'days': 7},
      {'label': '1M', 'days': 30},
      {'label': '1Y', 'days': 365},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...filterOptions.map((range) => _buildFilterButton(
              range['label'] as String,
              range['days'] as int,
              selectedThemeData,
            )),
        _buildFilterButton('Custom Dates', 0, selectedThemeData,
            isCustom: true),
      ],
    );
  }

  Widget _buildFilterButton(String label, int days, ThemeData selectedThemeData,
      {bool isCustom = false}) {
    final bool isActive = activeButton == label;
    return GestureDetector(
      onTap: isCustom ? _pickDateRange : () => _setDateRange(label, days),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? selectedThemeData.primaryColor
              : selectedThemeData.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? selectedThemeData.primaryColor : Colors.grey,
            width: 0.4,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : selectedThemeData.canvasColor,
          ),
        ),
      ),
    );
  }
}
