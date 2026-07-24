import 'package:dio/dio.dart';
import 'package:learning_management_system_trainer/data/network/network_manager.dart';
import 'package:learning_management_system_trainer/domain/entities/student_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/student_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'remote_admin_auth_repository.dart';

class RemoteStudentRepository implements StudentRepository {
  final NetworkManager _networkManager = getIt<NetworkManager>();

  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass';
  }

  @override
  Future<List<StudentUser>> getAllUsers() async {
    return await _networkManager.get<List<StudentUser>>(
      path: '/users',
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['users'] ?? []);
        return data.map((item) => StudentUser.fromJson(item)).toList();
      },
    );
  }

  @override
  Future<void> createUser(StudentUser user) async {
    await _networkManager.post(
      path: '/register',
      body: user.toJson(),
      converter: (json) => json,
    );
  }

  @override
  Future<void> updateUser(StudentUser user) async {
    await _networkManager.put(
      path: '/users/${user.id}',
      body: user.toJson(),
      converter: (json) => json,
    );
  }

  @override
  Future<void> deleteUser(int id) async {
    await _networkManager.delete(
      path: '/users/$id',
      converter: (json) => json,
    );
  }

  @override
  Future<void> enrollUserToCourse({required String email, required String courseId}) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await _networkManager.post(
      path: '/admin/course-users',
      body: FormData.fromMap({
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'email': email,
        'course_id': courseId,
      }),
      converter: (json) => json,
    );
  }
}
