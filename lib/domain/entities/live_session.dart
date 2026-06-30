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

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      courseId: json['course_id']?.toString() ?? '',
      moduleId: json['module_id']?.toString(),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      meetingUrl: json['meeting_url'] ?? '',
      notes: json['notes'],
      recordingUrl: json['recording_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_id': courseId,
      'module_id': moduleId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'meeting_url': meetingUrl,
      'notes': notes,
      'recording_url': recordingUrl,
    };
  }
}
