class CastCrewItem {
  final int? id;
  final int? contentId;
  final int? seasonId;
  final String name;
  final String role;
  final String image;
  final String description;
  final bool isCrew;

  CastCrewItem({
    required this.id,
    required this.contentId,
    required this.seasonId,
    required this.name,
    required this.role,
    required this.image,
    required this.description,
    required this.isCrew,
  });

  factory CastCrewItem.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    final role = (json['role'] ?? '').toString().trim();
    final roleLower = role.toLowerCase();
    final isCrew = roleLower.isNotEmpty &&
        !roleLower.contains('actor') &&
        !roleLower.contains('actress') &&
        !roleLower.contains('cast');

    return CastCrewItem(
      id: toInt(json['castId'] ?? json['id']),
      contentId: toInt(json['contentId']),
      seasonId: toInt(json['seasonId']),
      name: (json['name'] ?? '').toString().trim(),
      role: role,
      image: (json['image'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      isCrew: isCrew,
    );
  }
}
