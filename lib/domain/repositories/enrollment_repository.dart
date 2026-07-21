import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';

abstract class EnrollmentRepository {
  Future<void> addUserToCourse({required String email, required String courseId});
  Future<void> removeUserFromCourse({required String email, required String courseId});
  Future<List<AdminUser>> getEnrolledUsers(String courseId);
}
