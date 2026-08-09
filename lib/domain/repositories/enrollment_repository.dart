import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/entities/enrollment.dart';

abstract class EnrollmentRepository {
  Future<void> addUserToCourse({
    required String email,
    required String courseId,
    String? paymentPlan,
    int? paidInstallments,
  });
  Future<void> removeUserFromCourse({required String email, required String courseId});
  Future<List<AdminUser>> getEnrolledUsers(String courseId);

  // Admin Enrollment Management
  Future<List<Enrollment>> listEnrollments({String? status});
  Future<Enrollment> getEnrollment(int id);
  Future<void> verifyPayment(int id);
  Future<void> admitUser(int id);
  Future<void> rejectEnrollment(int id);
  Future<void> resendSetupEmail(int id);
}
