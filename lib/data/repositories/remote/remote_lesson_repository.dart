import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:learning_management_system_trainer/domain/entities/lesson.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import '../../network/network_manager.dart';
import '../../../domain/repositories/lesson_repository.dart';

class RemoteLessonRepository implements LessonRepository {
  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass'; // Fallback for development
  }

  @override
  Future<Lesson> createLesson(Lesson lesson) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final result = await getIt<NetworkManager>().post<Lesson>(
      path: '/admin/lessons',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': lesson.id,
        'module_id': lesson.moduleId,
        'title': lesson.title,
        'lesson_type': lesson.lessonType.name,
        'content': lesson.content,
        'resources': lesson.resources.map((r) => _resourceToMap(r)).toList(),
      },
      converter: (json) => _mapJsonToLesson(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Created lesson: ${lesson.title}',
    );

    return result;
  }

  @override
  Future<void> deleteLesson(String id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().delete(
      path: '/admin/lessons',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': id,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Deleted lesson ID: $id',
    );
  }

  @override
  Future<List<Lesson>> getLessonsByModuleId(String moduleId) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<List<Lesson>>(
      path: '/admin/lessons',
      queryParameters: {
        'module_id': moduleId,
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['lessons'] ?? []);
        return data.map((item) => _mapJsonToLesson(item)).toList();
      },
    );
  }

  @override
  Future<void> reorderLessons(List<String> lessonIds) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/lessons/reorder',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'lesson_ids': lessonIds,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Reordered lessons',
    );
  }

  @override
  Future<Lesson> updateLesson(Lesson lesson) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final result = await getIt<NetworkManager>().put<Lesson>(
      path: '/admin/lessons',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': lesson.id,
        'title': lesson.title,
        'lesson_type': lesson.lessonType.name,
        'content': lesson.content,
        'resources': lesson.resources.map((r) => _resourceToMap(r)).toList(),
      },
      converter: (json) => _mapJsonToLesson(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Updated lesson: ${lesson.title}',
    );

    return result;
  }

  Lesson _mapJsonToLesson(dynamic json) {
    var resourcesData = json['resources'];
    List<LessonResource> resources = [];
    if (resourcesData != null) {
      try {
        final List<dynamic> list = resourcesData is String 
          ? jsonDecode(resourcesData) 
          : resourcesData;
        resources = list.map((item) => _mapJsonToResource(item)).toList();
      } catch (e) {
        debugPrint('Error parsing lesson resources: $e');
      }
    }

    return Lesson(
      id: json['id']?.toString() ?? '',
      moduleId: json['module_id']?.toString() ?? '',
      title: json['title'] ?? '',
      lessonType: LessonType.values.firstWhere(
        (e) => e.name == json['lesson_type'],
        orElse: () => LessonType.text,
      ),
      content: json['content'],
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      resources: resources,
    );
  }

  LessonResource _mapJsonToResource(dynamic json) {
    return LessonResource(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      fileType: json['file_type'] ?? json['fileType'] ?? '',
    );
  }

  Map<String, dynamic> _resourceToMap(LessonResource resource) {
    return {
      'id': resource.id,
      'title': resource.title,
      'url': resource.url,
      'file_type': resource.fileType,
    };
  }
}
