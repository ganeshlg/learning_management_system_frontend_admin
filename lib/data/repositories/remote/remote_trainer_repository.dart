import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/trainer_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import '../../network/network_manager.dart';

class RemoteTrainerRepository implements TrainerRepository {

  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    // Fallback or throw error if password is not available
    // In a production app, this should be handled more robustly
    return 'superadminpass';
  }

  @override
  Future<List<AdminUser>> getTrainers() async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<List<AdminUser>>(
      path: '/admin/trainers',
      queryParameters: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['trainers'] ?? []);
        return data.map((item) => AdminUser.fromJson(item)).toList();
      },
    );
  }

  @override
  Future<AdminUser> addTrainer(AdminUser trainer) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().post<AdminUser>(
      path: '/admin/trainers',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'trainer_email': trainer.email,
        'trainer_password': 'trainerpass',
        'trainer_name': trainer.name,
      },
      converter: (json) => AdminUser.fromJson(json),
    );
  }

  @override
  Future<AdminUser> updateTrainer(AdminUser trainer) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().put<AdminUser>(
      path: '/admin/trainers',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'trainer_email': trainer.email,
        'trainer_name': trainer.name,
        'trainer_password': 'newpass', // Placeholder for password update
      },
      converter: (json) => AdminUser.fromJson(json),
    );
  }

  @override
  Future<void> removeTrainer(int id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    // The API requires trainer_email, so we fetch all trainers to find the email associated with the ID
    final trainers = await getTrainers();
    final trainer = trainers.firstWhere((t) => t.id == id);

    await getIt<NetworkManager>().delete(
      path: '/admin/trainers',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'trainer_email': trainer.email,
      },
      converter: (json) => json,
    );
  }
}
