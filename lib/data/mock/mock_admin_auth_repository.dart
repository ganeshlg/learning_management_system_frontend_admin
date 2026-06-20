import 'dart:async';
import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';

class MockAdminAuthRepository implements AdminAuthRepository {
  final _controller = StreamController<AdminUser?>.broadcast();
  AdminUser? _currentUser;

  @override
  Future<AdminUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<AdminUser?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final user = MockData.admins.firstWhere(
        (u) => u.email == email && password == 'password',
      );
      _currentUser = user;
      _controller.add(_currentUser);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Stream<AdminUser?> get authStateChanges => _controller.stream;
}
