import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/entities/activity.dart';
import 'package:learning_management_system_trainer/domain/entities/dashboard_stats.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/dashboard_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import '../../network/network_manager.dart';

class RemoteDashboardRepository implements DashboardRepository {
  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass';
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<DashboardStats>(
      path: '/admin/dashboard/stats',
      queryParameters: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) {
        final summary = json['summary'] ?? {};
        final trends = (json['enrollment_trend'] as List? ?? [])
            .map((e) => EnrollmentTrend.fromJson(e))
            .toList();
        final activities = (json['recent_activities'] as List? ?? [])
            .map((e) => Activity.fromJson(e))
            .toList();

        return DashboardStats(
          totalCourses: summary['total_courses'] ?? 0,
          totalModules: summary['total_modules'] ?? 0,
          totalLessons: summary['total_lessons'] ?? 0,
          totalStudents: summary['total_students'] ?? 0,
          enrollmentTrend: trends,
          recentActivities: activities,
        );
      },
    );
  }

  @override
  Future<List<Activity>> getRecentActivities() async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<List<Activity>>(
      path: '/admin/dashboard/recent-activities',
      queryParameters: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'limit': 20,
      },
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['activities'] ?? []);
        return data.map((item) => Activity.fromJson(item)).toList();
      },
    );
  }
}
