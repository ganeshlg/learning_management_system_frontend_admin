import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:learning_management_system_trainer/data/network/network_manager.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/file_upload_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';

class RemoteFileUploadRepository implements FileUploadRepository {
  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass';
  }

  @override
  Future<String> uploadBytes(Uint8List bytes, String fileName, {String? folder}) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final formData = FormData.fromMap({
      'admin_email': admin.email,
      'admin_password': adminPassword,
      'folder': folder ?? 'uploads',
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });

    final url = await getIt<NetworkManager>().post<String>(
      path: '/admin/upload',
      body: formData,
      converter: (json) => json['url']?.toString() ?? '',
    );

    if (url.isNotEmpty) {
      await getIt<ActivityRepository>().logActivity(
        user: admin.name,
        activity: 'Uploaded file: $fileName to ${folder ?? 'uploads'}',
      );
    }

    return url;
  }
}
