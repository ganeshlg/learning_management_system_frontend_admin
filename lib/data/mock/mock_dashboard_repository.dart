import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/activity.dart';
import 'package:learning_management_system_trainer/domain/entities/dashboard_stats.dart';
import 'package:learning_management_system_trainer/domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DashboardStats(
      totalCourses: MockData.courses.length,
      totalModules: MockData.modules.length,
      totalLessons: MockData.lessons.length,
      totalStudents: 1250,
      recentActivities: [
        Activity(id: '1', user: 'Admin', activity: 'Updated course: Web Development', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
        Activity(id: '2', user: 'Admin', activity: 'Published new module', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
        Activity(id: '3', user: 'System', activity: 'New student enrolled', timestamp: DateTime.now().subtract(const Duration(hours: 4))),
      ],
      enrollmentTrend: [
        EnrollmentTrend(month: '2023-01', count: 10),
        EnrollmentTrend(month: '2023-02', count: 25),
        EnrollmentTrend(month: '2023-03', count: 45),
        EnrollmentTrend(month: '2023-04', count: 30),
        EnrollmentTrend(month: '2023-05', count: 60),
      ],
    );
  }

  @override
  Future<List<Activity>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Activity(id: '1', user: 'Admin', activity: 'Updated course: Web Development', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      Activity(id: '2', user: 'Admin', activity: 'Published new module', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    ];
  }
}
