abstract class ActivityRepository {
  Future<void> logActivity({required String user, required String activity});
}
