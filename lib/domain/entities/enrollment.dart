import 'package:learning_management_system_trainer/domain/entities/student_user.dart';

class Enrollment {
  final int id;
  final int userId;
  final int courseId;
  final String status; // 'pending_review', 'admitted', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentProofUrl;
  final String? paymentTransactionId;
  final String? adminNotes;
  final StudentUser? user;
  final String? courseName;

  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paymentProofUrl,
    this.paymentTransactionId,
    this.adminNotes,
    this.user,
    this.courseName,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      courseId: json['course_id'] is int ? json['course_id'] : int.parse(json['course_id'].toString()),
      status: json['status'] ?? 'pending_review',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      paymentProofUrl: json['payment_proof_url'],
      paymentTransactionId: json['payment_transaction_id'],
      adminNotes: json['admin_notes'],
      user: json['user'] != null ? StudentUser.fromJson(json['user']) : null,
      courseName: json['course_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'payment_proof_url': paymentProofUrl,
      'payment_transaction_id': paymentTransactionId,
      'admin_notes': adminNotes,
      'user': user?.toJson(),
      'course_name': courseName,
    };
  }
}
