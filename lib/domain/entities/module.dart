import 'package:learning_management_system_trainer/domain/entities/lesson.dart';

enum ModuleType { recorded, live }

class Module {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String? videoUrl; // For pre-recorded
  final ModuleType type;
  final String? liveLink; // For live sessions
  final String? recordedVideoUrl; // For live session recordings
  final int order;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.videoUrl,
    this.type = ModuleType.recorded,
    this.liveLink,
    this.recordedVideoUrl,
    required this.order,
    this.lessons = const [],
  });

  Module copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? videoUrl,
    ModuleType? type,
    String? liveLink,
    String? recordedVideoUrl,
    int? order,
    List<Lesson>? lessons,
  }) {
    return Module(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      liveLink: liveLink ?? this.liveLink,
      recordedVideoUrl: recordedVideoUrl ?? this.recordedVideoUrl,
      order: order ?? this.order,
      lessons: lessons ?? this.lessons,
    );
  }
}
