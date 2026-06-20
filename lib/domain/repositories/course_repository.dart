import 'package:learning_management_system_trainer/domain/entities/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course?> getCourseById(String id);
  Future<Course> createCourse(Course course);
  Future<Course> updateCourse(Course course);
  Future<void> deleteCourse(String id);
  Future<void> publishCourse(String id);
  Future<void> unpublishCourse(String id);
}
