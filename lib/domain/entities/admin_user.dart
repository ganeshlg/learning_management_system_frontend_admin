import 'package:learning_management_system_trainer/domain/entities/admin_role.dart';

class AdminUser {
  final int id;
  final String email;
  final String name;
  final AdminRole role;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] != null ? AdminRole.fromString(json['role'] as String) : AdminRole.trainer,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  AdminUser copyWith({
    int? id,
    String? email,
    String? name,
    AdminRole? role,
    DateTime? lastLogin,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}