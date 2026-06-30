import 'package:flutter/foundation.dart';
import 'package:learning_management_system_trainer/domain/entities/module.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/lesson_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import '../../network/network_manager.dart';
import '../../../domain/repositories/module_repository.dart';

class RemoteModuleRepository implements ModuleRepository {
  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass'; // Fallback
  }

  @override
  Future<Module> createModule(Module module) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final result = await getIt<NetworkManager>().post<Module>(
      path: '/admin/modules',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': module.id,
        'course_id': module.courseId,
        'title': module.title,
        'description': module.description,
        'video_url': module.videoUrl,
        'type': module.type.name,
        'live_link': module.liveLink,
        'recorded_video_url': module.recordedVideoUrl,
      },
      converter: (json) => _mapJsonToModule(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Created module: ${module.title}',
    );

    return result;
  }

  @override
  Future<void> deleteModule(String id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().delete(
      path: '/admin/modules',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': id,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Deleted module ID: $id',
    );
  }

  @override
  Future<List<Module>> getModulesByCourseId(String courseId) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final modules = await getIt<NetworkManager>().get<List<Module>>(
      path: '/admin/modules',
      queryParameters: {
        'course_id': courseId,
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['modules'] ?? []);
        return data.map((item) => _mapJsonToModule(item)).toList();
      },
    );

    // Fetch lessons for each module to populate the UI correctly
    final updatedModules = await Future.wait(modules.map((module) async {
      try {
        final lessons = await getIt<LessonRepository>().getLessonsByModuleId(module.id);
        return module.copyWith(lessons: lessons);
      } catch (e) {
        debugPrint('Error fetching lessons for module ${module.id}: $e');
        return module;
      }
    }));

    return updatedModules;
  }

  @override
  Future<void> reorderModules(List<String> moduleIds) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/modules/reorder',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'module_ids': moduleIds,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Reordered modules',
    );
  }

  @override
  Future<Module> updateModule(Module module) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final result = await getIt<NetworkManager>().put<Module>(
      path: '/admin/modules',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': module.id,
        'title': module.title,
        'description': module.description,
        'video_url': module.videoUrl,
        'type': module.type.name,
        'live_link': module.liveLink,
        'recorded_video_url': module.recordedVideoUrl,
      },
      converter: (json) => _mapJsonToModule(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Updated module: ${module.title}',
    );

    return result;
  }

  Module _mapJsonToModule(dynamic json) {
    final typeStr = json['type']?.toString().toLowerCase() ?? '';
    return Module(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      videoUrl: json['video_url'],
      type: typeStr == 'live' ? ModuleType.live : ModuleType.recorded,
      liveLink: json['live_link'],
      recordedVideoUrl: json['recorded_video_url'],
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      lessons: [],
    );
  }
}
