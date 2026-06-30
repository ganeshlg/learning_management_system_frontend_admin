class Activity {
  final String id;
  final String user;
  final String activity;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.user,
    required this.activity,
    required this.timestamp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString() ?? '',
      user: json['user'] ?? '',
      activity: json['activity'] ?? '',
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : (json['timestamp'] != null 
              ? DateTime.parse(json['timestamp']) 
              : DateTime.now()),
    );
  }
}
