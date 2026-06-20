import 'package:get_it/get_it.dart';
import 'package:learning_management_system_trainer/data/mock/mock_admin_auth_repository.dart';
import 'package:learning_management_system_trainer/data/mock/mock_course_repository.dart';
import 'package:learning_management_system_trainer/data/mock/mock_dashboard_repository.dart';
import 'package:learning_management_system_trainer/data/mock/mock_lesson_repository.dart';
import 'package:learning_management_system_trainer/data/mock/mock_live_session_repository.dart';
import 'package:learning_management_system_trainer/data/mock/mock_module_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_trainer_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/dashboard_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/lesson_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/live_session_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/module_repository.dart';

import 'package:learning_management_system_trainer/data/mock/mock_resource_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/resource_repository.dart';

import 'package:learning_management_system_trainer/data/mock/mock_trainer_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/trainer_repository.dart';

import '../../data/network/network_manager.dart';

final getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  // Repositories
  // getIt.registerLazySingleton<AdminAuthRepository>(() => MockAdminAuthRepository());
  getIt.registerLazySingleton<CourseRepository>(() => MockCourseRepository());
  getIt.registerLazySingleton<DashboardRepository>(() => MockDashboardRepository());
  getIt.registerLazySingleton<ModuleRepository>(() => MockModuleRepository());
  getIt.registerLazySingleton<LessonRepository>(() => MockLessonRepository());
  getIt.registerLazySingleton<LiveSessionRepository>(() => MockLiveSessionRepository());
  getIt.registerLazySingleton<ResourceRepository>(() => MockResourceRepository());
  // getIt.registerLazySingleton<TrainerRepository>(() => MockTrainerRepository());

  //Remote Repositories
  getIt.registerLazySingleton<AdminAuthRepository>(() => RemoteAdminAuthRepository());
  getIt.registerLazySingleton<TrainerRepository>(() => RemoteTrainerRepository());


  //Network Manager
  getIt.registerLazySingleton<NetworkManager>(
        () => NetworkManager(
      // baseUrl: 'http://localhost:8000/api',
      baseUrl: 'https://learning-management-system-api-gateway-v1.onrender.com/api',
      allowBadCertificates: false,
    ),
  );
}
