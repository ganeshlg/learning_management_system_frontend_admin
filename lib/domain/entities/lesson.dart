enum LessonType { video, liveSession, text, resource, assignment, quiz }

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
  final String? videoUrl;
  final String? pdfUrl;
  final String? content;
  final List<LessonResource> resources;
  final String? assignmentInstructions;
  final String? quizReferenceId;
  final DateTime? sessionDate;
  final String? sessionLink;
  final int order;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.lessonType,
    this.videoUrl,
    this.content,
    this.resources = const [],
    this.assignmentInstructions,
    this.quizReferenceId,
    this.sessionDate,
    this.sessionLink,
    required this.order,
    this.pdfUrl,
  });

  Lesson copyWith({
    String? id,
    String? moduleId,
    String? title,
    LessonType? lessonType,
    String? videoUrl,
    String? content,
    List<LessonResource>? resources,
    String? assignmentInstructions,
    String? quizReferenceId,
    DateTime? sessionDate,
    String? sessionLink,
    int? order,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      lessonType: lessonType ?? this.lessonType,
      videoUrl: videoUrl ?? this.videoUrl,
      content: content ?? this.content,
      resources: resources ?? this.resources,
      assignmentInstructions:
          assignmentInstructions ?? this.assignmentInstructions,
      quizReferenceId: quizReferenceId ?? this.quizReferenceId,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionLink: sessionLink ?? this.sessionLink,
      order: order ?? this.order,
    );
  }
}
