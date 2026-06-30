import 'dart:math';

import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/entities/course_status.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../network/network_manager.dart';

class RemoteCourseRepository implements CourseRepository {

  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass'; // Fallback
  }

  @override
  Future<Course> createCourse(Course course) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final result = await getIt<NetworkManager>().post<Course>(
      path: '/admin/courses',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': List.generate(10, (_) => Random().nextInt(10)).join(),
        'title': course.title,
        'description': course.description,
        'price': course.price,
        'duration_hours': course.durationHours,
        'instructor_name': course.instructorName,
        'thumbnail_url': course.thumbnailUrl,
        'meta_title': course.metaTitle,
        'meta_description': course.metaDescription,
      },
      converter: (json) => _mapJsonToCourse(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Created course: ${course.title}',
    );

    return result;
  }

  @override
  Future<void> deleteCourse(String id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().delete(
      path: '/admin/courses',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': id,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Deleted course ID: $id',
    );
  }

  @override
  Future<Course?> getCourseById(String id) async {
    final courses = await getCourses();
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Course>> getCourses() async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<List<Course>>(
      path: '/admin/courses',
      queryParameters: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['courses'] ?? []);
        return data.map((item) => _mapJsonToCourse(item)).toList();
      },
    );
  }

  @override
  Future<void> publishCourse(String id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/courses/publish',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': id,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Published course ID: $id',
    );
  }

  @override
  Future<void> unpublishCourse(String id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    await getIt<NetworkManager>().post(
      path: '/admin/courses/unpublish',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': id,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Unpublished course ID: $id',
    );
  }

  @override
  Future<Course> updateCourse(Course course) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final result = await getIt<NetworkManager>().put<Course>(
      path: '/admin/courses',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'id': course.id,
        'title': course.title,
        'description': course.description,
        'price': course.price,
        'duration_hours': course.durationHours,
        'instructor_name': course.instructorName,
        'thumbnail_url': course.thumbnailUrl,
        'meta_title': course.metaTitle,
        'meta_description': course.metaDescription,
      },
      converter: (json) => _mapJsonToCourse(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Updated course: ${course.title}',
    );

    return result;
  }

  Course _mapJsonToCourse(dynamic json) {
    return Course(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      price: double.parse((json['price'] ?? "0").toString()),
      durationHours: json['duration_hours'] ?? 0,
      instructorName: json['instructor_name'] ?? '',
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      status: json['is_published'] == true || json['is_published'] == 'true'
          ? CourseStatus.published
          : CourseStatus.draft,
      modules: []
    );
  }
}
