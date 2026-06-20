import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';

abstract class TrainerRepository {
  Future<List<AdminUser>> getTrainers();
  Future<AdminUser> addTrainer(AdminUser trainer);
  Future<AdminUser> updateTrainer(AdminUser trainer);
  Future<void> removeTrainer(int id);
}
