import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/lesson.dart';
import 'package:learning_management_system_trainer/domain/repositories/lesson_repository.dart';

class MockLessonRepository implements LessonRepository {
  @override
  Future<List<Lesson>> getLessonsByModuleId(String moduleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.lessons.where((l) => l.moduleId == moduleId).toList();
  }

  @override
  Future<Lesson> createLesson(Lesson lesson) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newLesson = Lesson(
      id: 'lesson-${MockData.lessons.length + 1}',
      moduleId: lesson.moduleId,
      title: lesson.title,
      lessonType: lesson.lessonType,
      order: lesson.order,
    );
    MockData.lessons.add(newLesson);
    return newLesson;
  }

  @override
  Future<Lesson> updateLesson(Lesson lesson) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = MockData.lessons.indexWhere((l) => l.id == lesson.id);
    if (index != -1) {
      MockData.lessons[index] = lesson;
    }
    return lesson;
  }

  @override
  Future<void> deleteLesson(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.lessons.removeWhere((l) => l.id == id);
  }

  @override
  Future<void> reorderLessons(List<String> lessonIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < lessonIds.length; i++) {
      final index = MockData.lessons.indexWhere((l) => l.id == lessonIds[i]);
      if (index != -1) {
        final lesson = MockData.lessons[index];
        MockData.lessons[index] = Lesson(
          id: lesson.id,
          moduleId: lesson.moduleId,
          title: lesson.title,
          lessonType: lesson.lessonType,
          order: i,
        );
      }
    }
  }
}
