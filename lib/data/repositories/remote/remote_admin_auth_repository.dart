import 'dart:async';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import '../../../domain/repositories/admin_auth_repository.dart';
import '../../../domain/services/service_locator.dart';
import '../../network/network_manager.dart';

class RemoteAdminAuthRepository implements AdminAuthRepository {
  final _controller = StreamController<AdminUser?>.broadcast();
  AdminUser? _currentUser;
  String? _password;

  String? get currentPassword => _password;

  @override
  Stream<AdminUser?> get authStateChanges => _controller.stream;

  @override
  Future<AdminUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<AdminUser?> login(String email, String password) async {
    try {
      AdminUser adminUser = await getIt<NetworkManager>().post<AdminUser>(
        path: '/admin/login',
        body: {'email': email, 'password': password},
        converter: (json) => AdminUser.fromJson(json),
      );
      _currentUser = adminUser;
      _password = password;
      _controller.add(_currentUser);
    } catch (e) {
      _currentUser = null;
      _password = null;
      return null;
    }
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _password = null;
    _controller.add(null);
  }
}
