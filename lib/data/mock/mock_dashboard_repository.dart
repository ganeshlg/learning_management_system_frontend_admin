import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
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
      activeLiveSessions: MockData.liveSessions.length,
    );
  }
}
