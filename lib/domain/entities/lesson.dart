enum LessonType { liveSession, text, resource, assignment, quiz }

class LessonResource {
  final String id;
  final String title;
  final String url;
  final String fileType;

  LessonResource({
    required this.id,
    required this.title,
    required this.url,
    required this.fileType,
  });

  LessonResource copyWith({
    String? id,
    String? title,
    String? url,
    String? fileType,
  }) {
    return LessonResource(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      fileType: fileType ?? this.fileType,
    );
  }
}

class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final LessonType lessonType;
  final String? content;
  final List<LessonResource> resources;
  final int order;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.lessonType,
    this.content,
    this.resources = const [],
    required this.order,
  });

  Lesson copyWith({
    String? id,
    String? moduleId,
    String? title,
    LessonType? lessonType,
    String? content,
    List<LessonResource>? resources,
    int? order,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      lessonType: lessonType ?? this.lessonType,
      content: content ?? this.content,
      resources: resources ?? this.resources,
      order: order ?? this.order,
    );
  }
}
