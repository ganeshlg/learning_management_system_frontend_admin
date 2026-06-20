class LiveSession {
  final String id;
  final String title;
  final String courseId;
  final String? moduleId;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingUrl;
  final String? notes;
  final String? recordingUrl;

  LiveSession({
    required this.id,
    required this.title,
    required this.courseId,
    this.moduleId,
    required this.startTime,
    required this.endTime,
    required this.meetingUrl,
    this.notes,
    this.recordingUrl,
  });
}
