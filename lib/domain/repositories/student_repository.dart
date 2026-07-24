import '../entities/student_user.dart';

abstract class StudentRepository {
  Future<List<StudentUser>> getAllUsers();
  Future<void> createUser(StudentUser user);
  Future<void> updateUser(StudentUser user);
  Future<void> deleteUser(int id);
  Future<void> enrollUserToCourse({required String email, required String courseId});
}
