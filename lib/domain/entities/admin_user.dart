import 'package:learning_management_system_trainer/domain/entities/admin_role.dart';

class AdminUser {
  final int id;
  final String email;
  final String name;
  final AdminRole role;
  final DateTime? lastLogin;
  final String? profileDescription;
  final int? experienceYears;
  final List<String>? expertise;
  final String? phone;
  final String? location;
  final String? linkedinUrl;
  final String? websiteUrl;
  final String? photoUrl;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.lastLogin,
    this.profileDescription,
    this.experienceYears,
    this.expertise,
    this.phone,
    this.location,
    this.linkedinUrl,
    this.websiteUrl,
    this.photoUrl,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id']?.toString() ?? '0'),
      email: (json['email'] ?? json['trainer_email']) as String,
      name: (json['name'] ?? json['trainer_name']) as String,
      role: json['role'] != null ? AdminRole.fromString(json['role'] as String) : AdminRole.trainer,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      profileDescription: json['profile_description'] as String?,
      experienceYears: json['experience_years'] is int 
          ? json['experience_years'] as int 
          : int.tryParse(json['experience_years']?.toString() ?? ''),
      expertise: json['expertise'] is List 
          ? (json['expertise'] as List).map((e) => e.toString()).toList()
          : (json['expertise'] is String 
              ? (json['expertise'] as String).split(',').map((e) => e.trim()).toList() 
              : null),
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      photoUrl: json['photo_url'] ?? json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'lastLogin': lastLogin?.toIso8601String(),
      'profile_description': profileDescription,
      'experience_years': experienceYears,
      'expertise': expertise,
      'phone': phone,
      'location': location,
      'linkedin_url': linkedinUrl,
      'website_url': websiteUrl,
      'photo_url': photoUrl,
    };
  }

  AdminUser copyWith({
    int? id,
    String? email,
    String? name,
    AdminRole? role,
    DateTime? lastLogin,
    String? profileDescription,
    int? experienceYears,
    List<String>? expertise,
    String? phone,
    String? location,
    String? linkedinUrl,
    String? websiteUrl,
    String? photoUrl,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      profileDescription: profileDescription ?? this.profileDescription,
      experienceYears: experienceYears ?? this.experienceYears,
      expertise: expertise ?? this.expertise,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}