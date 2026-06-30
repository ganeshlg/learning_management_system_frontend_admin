import 'package:learning_management_system_trainer/domain/entities/dashboard_stats.dart';
import 'package:learning_management_system_trainer/domain/entities/activity.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<Activity>> getRecentActivities();
}
