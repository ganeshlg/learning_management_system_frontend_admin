import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import '../../network/network_manager.dart';

class RemoteActivityRepository implements ActivityRepository {
  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass';
  }

  @override
  Future<void> logActivity({required String user, required String activity}) async {
    try {
      final admin = await getIt<AdminAuthRepository>().getCurrentUser();
      final adminPassword = await _getAdminPassword();

      await getIt<NetworkManager>().post(
        path: '/admin/activity',
        body: {
          'admin_email': admin?.email ?? 'admin@example.com',
          'admin_password': adminPassword,
          'user': user,
          'activity': activity,
        },
        converter: (json) => json,
      );
    } catch (e) {
      // We might not want to crash the app if activity logging fails
      print('Failed to log activity: $e');
    }
  }
}
