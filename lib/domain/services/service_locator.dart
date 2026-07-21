import 'package:get_it/get_it.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_dashboard_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_activity_repository.dart';
import 'package:learning_management_system_trainer/domain/constants/AppConstants.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_lesson_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_trainer_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_file_upload_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/dashboard_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/file_upload_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/lesson_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/module_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_enrollment_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/enrollment_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/trainer_repository.dart';
import '../../data/network/network_manager.dart';
import '../../data/repositories/remote/remote_course_repository.dart';
import '../../data/repositories/remote/remote_module_repository.dart';

final getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  getIt.registerLazySingleton<DashboardRepository>(() => RemoteDashboardRepository());
  getIt.registerLazySingleton<AdminAuthRepository>(() => RemoteAdminAuthRepository());
  getIt.registerLazySingleton<TrainerRepository>(() => RemoteTrainerRepository());
  getIt.registerLazySingleton<CourseRepository>(() => RemoteCourseRepository());
  getIt.registerLazySingleton<ModuleRepository>(() => RemoteModuleRepository());
  getIt.registerLazySingleton<LessonRepository>(() => RemoteLessonRepository());
  getIt.registerLazySingleton<FileUploadRepository>(() => RemoteFileUploadRepository());
  getIt.registerLazySingleton<ActivityRepository>(() => RemoteActivityRepository());
  getIt.registerLazySingleton<EnrollmentRepository>(() => RemoteEnrollmentRepository());

  //Network Manager
  getIt.registerLazySingleton<NetworkManager>(
        () => NetworkManager(
      baseUrl: AppConstants.baseUrl,
      allowBadCertificates: false,
    ),
  );
}
