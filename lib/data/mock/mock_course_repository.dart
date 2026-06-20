import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/entities/course_status.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';

class MockCourseRepository implements CourseRepository {
  @override
  Future<List<Course>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.courses;
  }

  @override
  Future<Course?> getCourseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return MockData.courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Course> createCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newCourse = course.copyWith(id: 'course-${MockData.courses.length + 1}');
    MockData.courses.add(newCourse);
    return newCourse;
  }

  @override
  Future<Course> updateCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = MockData.courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      MockData.courses[index] = course;
    }
    return course;
  }

  @override
  Future<void> deleteCourse(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    MockData.courses.removeWhere((course) => course.id == id);
  }

  @override
  Future<void> publishCourse(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = MockData.courses.indexWhere((c) => c.id == id);
    if (index != -1) {
      MockData.courses[index] = MockData.courses[index].copyWith(status: CourseStatus.published);
    }
  }

  @override
  Future<void> unpublishCourse(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = MockData.courses.indexWhere((c) => c.id == id);
    if (index != -1) {
      MockData.courses[index] = MockData.courses[index].copyWith(status: CourseStatus.draft);
    }
  }
}
