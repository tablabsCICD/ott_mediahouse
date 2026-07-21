class WeeklySettlementReportResponse {
  final bool success;
  final String message;
  final int statusCode;
  final WeeklySettlementReportData data;

  const WeeklySettlementReportResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory WeeklySettlementReportResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Settlement report data is missing.');
    }
    return WeeklySettlementReportResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: _asInt(json['statusCode']),
      data: WeeklySettlementReportData.fromJson(
          Map<String, dynamic>.from(rawData)),
    );
  }
}

class WeeklySettlementReportData {
  final String title;
  final String reportType;
  final String settlementBatchReference;
  final String settlementStatus;
  final SettlementBeneficiary? beneficiary;
  final List<ReportEntry> summaryCards;
  final List<ReportSection> sections;
  final List<ReportEntry> beneficiarySettlementSummary;
  final Map<String, dynamic> taxAndChargeSummary;
  final List<ReportEntry> finalSummary;

  const WeeklySettlementReportData({
    required this.title,
    required this.reportType,
    required this.settlementBatchReference,
    required this.settlementStatus,
    required this.beneficiary,
    required this.summaryCards,
    required this.sections,
    required this.beneficiarySettlementSummary,
    required this.taxAndChargeSummary,
    required this.finalSummary,
  });

  factory WeeklySettlementReportData.fromJson(Map<String, dynamic> json) =>
      WeeklySettlementReportData(
        title: json['title']?.toString() ?? '',
        reportType: json['reportType']?.toString() ?? '',
        settlementBatchReference:
            json['settlementBatchReference']?.toString() ?? '',
        settlementStatus: json['settlementStatus']?.toString() ?? 'UNKNOWN',
        beneficiary: json['beneficiary'] is Map
            ? SettlementBeneficiary.fromJson(
                Map<String, dynamic>.from(json['beneficiary'] as Map))
            : null,
        summaryCards: _entries(json['summaryCards']),
        sections: _sections(json['sections']),
        beneficiarySettlementSummary:
            _entries(json['beneficiarySettlementSummary']),
        taxAndChargeSummary: json['taxAndChargeSummary'] is Map
            ? Map<String, dynamic>.from(json['taxAndChargeSummary'] as Map)
            : const {},
        finalSummary: _entries(json['finalSummary']),
      );

  bool get hasCalculations =>
      summaryCards.isNotEmpty ||
      sections.isNotEmpty ||
      beneficiarySettlementSummary.isNotEmpty ||
      taxAndChargeSummary.isNotEmpty ||
      finalSummary.isNotEmpty;
}

class SettlementBeneficiary {
  final int? beneficiaryId;
  final String beneficiaryType;
  final String beneficiaryName;
  final String? promoterLevel;

  const SettlementBeneficiary({
    required this.beneficiaryId,
    required this.beneficiaryType,
    required this.beneficiaryName,
    required this.promoterLevel,
  });

  factory SettlementBeneficiary.fromJson(Map<String, dynamic> json) =>
      SettlementBeneficiary(
        beneficiaryId: _asNullableInt(json['beneficiaryId']),
        beneficiaryType: json['beneficiaryType']?.toString() ?? '',
        beneficiaryName: json['beneficiaryName']?.toString() ?? '',
        promoterLevel: _nullableText(json['promoterLevel']),
      );
}

/// Flexible report entry: known display fields remain available while the full
/// payload is retained for backend additions.
class ReportEntry {
  final Map<String, dynamic> fields;
  const ReportEntry(this.fields);

  String get label => _firstText(fields, const [
        'label', 'title', 'name', 'key', 'description'
      ]);
  dynamic get value => _firstValue(fields, const [
        'value', 'amount', 'count', 'percentage', 'total'
      ]);
}

class ReportSection {
  final String title;
  final List<ReportEntry> entries;
  final Map<String, dynamic> fields;

  const ReportSection({
    required this.title,
    required this.entries,
    required this.fields,
  });

  factory ReportSection.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'] ?? json['entries'] ?? json['items'] ?? json['data'];
    return ReportSection(
      title: _firstText(json, const ['title', 'sectionTitle', 'name', 'label']),
      entries: _entries(rawRows),
      fields: json,
    );
  }
}

List<ReportEntry> _entries(dynamic raw) {
  if (raw is List) {
    return raw.map((item) {
      if (item is Map) return ReportEntry(Map<String, dynamic>.from(item));
      return ReportEntry({'value': item});
    }).toList(growable: false);
  }
  if (raw is Map) {
    return raw.entries
        .map((entry) => ReportEntry({'label': entry.key, 'value': entry.value}))
        .toList(growable: false);
  }
  return const [];
}

List<ReportSection> _sections(dynamic raw) => raw is List
    ? raw
        .whereType<Map>()
        .map((item) => ReportSection.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false)
    : const [];

dynamic _firstValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (map.containsKey(key) && map[key] != null) return map[key];
  }
  return null;
}

String _firstText(Map<String, dynamic> map, List<String> keys) =>
    _firstValue(map, keys)?.toString() ?? '';
String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
int? _asNullableInt(dynamic value) => value == null
    ? null
    : (value is num ? value.toInt() : int.tryParse('$value'));
