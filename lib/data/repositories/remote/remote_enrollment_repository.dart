import 'package:dio/dio.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/entities/enrollment.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/enrollment_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import '../../network/network_manager.dart';

class RemoteEnrollmentRepository implements EnrollmentRepository {
  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass';
  }

  @override
  Future<void> addUserToCourse({
    required String email,
    required String courseId,
    String? paymentPlan,
    int? paidInstallments,
  }) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/course-users',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'email': email,
        'course_id': courseId,
        'payment_plan': paymentPlan,
        'paid_installments': paidInstallments,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Enrolled user $email to course $courseId',
    );
  }

  @override
  Future<List<AdminUser>> getEnrolledUsers(String courseId) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<List<AdminUser>>(
      path: '/admin/course-users',
      queryParameters: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'course_id': courseId,
      },
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['users'] ?? []);
        return data.map((item) => AdminUser.fromJson(item)).toList();
      },
    );
  }

  @override
  Future<void> removeUserFromCourse({required String email, required String courseId}) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().delete(
      path: '/admin/course-users',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'email': email,
        'course_id': courseId,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Removed user $email from course $courseId',
    );
  }

  @override
  Future<List<Enrollment>> listEnrollments({String? status}) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final queryParameters = {
      'admin_email': admin.email,
      'admin_password': adminPassword,
    };
    if (status != null) {
      queryParameters['status'] = status;
    }

    return await getIt<NetworkManager>().get<List<Enrollment>>(
      path: '/admin/enrollments',
      queryParameters: queryParameters,
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['enrollments'] ?? []);
        return data.map((item) => Enrollment.fromJson(item)).toList();
      },
    );
  }

  @override
  Future<Enrollment> getEnrollment(int id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<Enrollment>(
      path: '/admin/enrollments/$id',
      queryParameters: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) => Enrollment.fromJson(json),
    );
  }

  @override
  Future<void> verifyPayment(int id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/enrollments/$id/verify-payment',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Verified payment for enrollment $id',
    );
  }

  @override
  Future<void> admitUser(int id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/enrollments/$id/admit',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Admitted enrollment $id',
    );
  }

  @override
  Future<void> rejectEnrollment(int id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/enrollments/$id/reject',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Rejected enrollment $id',
    );
  }

  @override
  Future<void> resendSetupEmail(int id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/enrollments/$id/resend-setup-email',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Resent setup email for enrollment $id',
    );
  }
}
