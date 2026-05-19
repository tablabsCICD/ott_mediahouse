class LanguageGroupResponse {
  const LanguageGroupResponse({
    this.majorIndianLanguages = const [],
    this.otherIndianLanguages = const [],
    this.foreignLanguages = const [],
  });

  final List<LanguageOption> majorIndianLanguages;
  final List<LanguageOption> otherIndianLanguages;
  final List<LanguageOption> foreignLanguages;

  factory LanguageGroupResponse.fromJson(Map<String, dynamic> json) {
    List<LanguageOption> readList(String key) {
      final value = json[key];
      if (value is! List) return const [];
      return value
          .whereType<Map>()
          .map((item) => LanguageOption.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }

    return LanguageGroupResponse(
      majorIndianLanguages: readList('majorIndianLanguages'),
      otherIndianLanguages: readList('otherIndianLanguages'),
      foreignLanguages: readList('foreignLanguages'),
    );
  }

  Map<String, List<String>> toGroupedNames() {
    return {
      'Major Indian Languages':
          majorIndianLanguages.map((item) => item.name).toList(),
      'Other Indian Languages':
          otherIndianLanguages.map((item) => item.name).toList(),
      'Foreign Languages': foreignLanguages.map((item) => item.name).toList(),
    }..removeWhere((_, value) => value.isEmpty);
  }

  List<String> toNames() {
    return toGroupedNames()
        .values
        .expand((items) => items)
        .where((item) => item.trim().isNotEmpty)
        .toSet()
        .toList();
  }
}

class LanguageOption {
  const LanguageOption({
    required this.id,
    required this.name,
    required this.native,
  });

  final int id;
  final String name;
  final String native;

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    return LanguageOption(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      native: json['native']?.toString().trim() ?? '',
    );
  }
}
