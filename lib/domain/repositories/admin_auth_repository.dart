import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';

abstract class AdminAuthRepository {
  Future<AdminUser?> login(String email, String password);
  Future<void> logout();
  Future<AdminUser?> getCurrentUser();
  Stream<AdminUser?> get authStateChanges;
}
