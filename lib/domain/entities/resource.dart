enum ResourceType {
  pdf,
  ppt,
  excel,
  zip,
  video,
}

class Resource {
  final String id;
  final String name;
  final ResourceType type;
  final String? url;
  final String? courseId;
  final String? moduleId;
  final String? lessonId;

  Resource({
    required this.id,
    required this.name,
    required this.type,
    this.url,
    this.courseId,
    this.moduleId,
    this.lessonId,
  });
}
