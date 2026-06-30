import 'package:learning_management_system_trainer/domain/entities/activity.dart';

class EnrollmentTrend {
  final String month;
  final int count;

  EnrollmentTrend({required this.month, required this.count});

  factory EnrollmentTrend.fromJson(Map<String, dynamic> json) {
    return EnrollmentTrend(
      month: json['month'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class DashboardStats {
  final int totalCourses;
  final int totalModules;
  final int totalLessons;
  final int totalStudents;
  final List<EnrollmentTrend> enrollmentTrend;
  final List<Activity> recentActivities;

  DashboardStats({
    required this.totalCourses,
    required this.totalModules,
    required this.totalLessons,
    required this.totalStudents,
    this.enrollmentTrend = const [],
    this.recentActivities = const [],
  });
}
