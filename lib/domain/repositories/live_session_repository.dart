import 'package:learning_management_system_trainer/domain/entities/live_session.dart';

abstract class LiveSessionRepository {
  Future<List<LiveSession>> getLiveSessions();
  Future<LiveSession> createLiveSession(LiveSession session);
  Future<LiveSession> updateLiveSession(LiveSession session);
  Future<void> deleteLiveSession(String id);
  Future<void> uploadRecording(String sessionId, String recordingUrl);
}
