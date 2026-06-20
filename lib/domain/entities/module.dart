import 'package:learning_management_system_trainer/domain/entities/lesson.dart';

class Module {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String? videoUrl;
  final int order;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.videoUrl,
    required this.order,
    this.lessons = const [],
  });

  Module copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? videoUrl,
    int? order,
    List<Lesson>? lessons,
  }) {
    return Module(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      order: order ?? this.order,
      lessons: lessons ?? this.lessons,
    );
  }
}
