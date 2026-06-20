import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_role.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/trainer_repository.dart';

class MockTrainerRepository implements TrainerRepository {
  @override
  Future<List<AdminUser>> getTrainers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.admins.where((u) => u.role == AdminRole.trainer).toList();
  }

  @override
  Future<AdminUser> addTrainer(AdminUser trainer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTrainer = AdminUser(
      id: MockData.admins.length + 1,
      email: trainer.email,
      name: trainer.name,
      role: AdminRole.trainer,
    );
    MockData.admins.add(newTrainer);
    return newTrainer;
  }

  @override
  Future<AdminUser> updateTrainer(AdminUser trainer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = MockData.admins.indexWhere((u) => u.id == trainer.id);
    if (index != -1) {
      MockData.admins[index] = trainer;
    }
    return trainer;
  }

  @override
  Future<void> removeTrainer(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    MockData.admins.removeWhere((u) => u.id == id && u.role == AdminRole.trainer);
  }
}
