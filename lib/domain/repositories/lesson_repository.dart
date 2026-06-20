import 'package:learning_management_system_trainer/domain/entities/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessonsByModuleId(String moduleId);
  Future<Lesson> createLesson(Lesson lesson);
  Future<Lesson> updateLesson(Lesson lesson);
  Future<void> deleteLesson(String id);
  Future<void> reorderLessons(List<String> lessonIds);
}
