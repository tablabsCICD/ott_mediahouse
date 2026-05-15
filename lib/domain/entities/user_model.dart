class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String department;
  final bool isOnline;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'isOnline': isOnline,
    };
  }
}
