import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/live_session.dart';
import 'package:learning_management_system_trainer/domain/repositories/live_session_repository.dart';

class MockLiveSessionRepository implements LiveSessionRepository {
  @override
  Future<List<LiveSession>> getLiveSessions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.liveSessions;
  }

  @override
  Future<LiveSession> createLiveSession(LiveSession session) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newSession = LiveSession(
      id: 'session-${MockData.liveSessions.length + 1}',
      title: session.title,
      courseId: session.courseId,
      moduleId: session.moduleId,
      startTime: session.startTime,
      endTime: session.endTime,
      meetingUrl: session.meetingUrl,
      notes: session.notes,
    );
    MockData.liveSessions.add(newSession);
    return newSession;
  }

  @override
  Future<LiveSession> updateLiveSession(LiveSession session) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = MockData.liveSessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      MockData.liveSessions[index] = session;
    }
    return session;
  }

  @override
  Future<void> deleteLiveSession(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.liveSessions.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> uploadRecording(String sessionId, String recordingUrl) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = MockData.liveSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      MockData.liveSessions[index] = LiveSession(
        id: MockData.liveSessions[index].id,
        title: MockData.liveSessions[index].title,
        courseId: MockData.liveSessions[index].courseId,
        moduleId: MockData.liveSessions[index].moduleId,
        startTime: MockData.liveSessions[index].startTime,
        endTime: MockData.liveSessions[index].endTime,
        meetingUrl: MockData.liveSessions[index].meetingUrl,
        notes: MockData.liveSessions[index].notes,
        recordingUrl: recordingUrl,
      );
    }
  }
}
