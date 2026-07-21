import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/activity_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/trainer_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/data/repositories/remote/remote_admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/file_upload_repository.dart';
import '../../network/network_manager.dart';
import 'dart:io';

class RemoteTrainerRepository implements TrainerRepository {

  Future<String> _getAdminPassword() async {
    final authRepo = getIt<AdminAuthRepository>();
    if (authRepo is RemoteAdminAuthRepository) {
      final password = authRepo.currentPassword;
      if (password != null) return password;
    }
    return 'superadminpass'; // Fallback
  }

  Future<String?> _uploadTrainerPhoto(String? localPath) async {
    if (localPath == null || localPath.startsWith('http') || localPath.isEmpty) return localPath;

    try {
      final bytes = kIsWeb 
          ? (await Dio().get(localPath, options: Options(responseType: ResponseType.bytes))).data
          : await File(localPath).readAsBytes();
      
      final fileName = 'trainer_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await getIt<FileUploadRepository>().uploadBytes(bytes, fileName, folder: 'trainers');
    } catch (e) {
      print('Failed to upload trainer photo: $e');
      return null;
    }
  }

  @override
  Future<List<AdminUser>> getTrainers() async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    return await getIt<NetworkManager>().get<List<AdminUser>>(
      path: '/admin/trainers',
      queryParameters: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
      },
      converter: (json) {
        final List<dynamic> data = json is List ? json : (json['trainers'] ?? []);
        return data.map((item) => AdminUser.fromJson(item)).toList();
      },
    );
  }

  @override
  Future<AdminUser> addTrainer(AdminUser trainer) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final photoUrl = await _uploadTrainerPhoto(trainer.photoUrl);

    final Map<String, dynamic> fields = {
      'admin_email': admin.email,
      'admin_password': adminPassword,
      'trainer_email': trainer.email,
      'trainer_password': 'trainerpass',
      'trainer_name': trainer.name,
      'profile_description': trainer.profileDescription ?? '',
      'experience_years': (trainer.experienceYears ?? 0).toString(),
      'expertise': trainer.expertise?.join(', ') ?? '',
      'phone': trainer.phone ?? '',
      'location': trainer.location ?? '',
      'linkedin_url': trainer.linkedinUrl ?? '',
      'website_url': trainer.websiteUrl ?? '',
      'photo_url': photoUrl ?? '',
    };

    final result = await getIt<NetworkManager>().post<AdminUser>(
      path: '/admin/trainers',
      body: fields,
      converter: (json) => AdminUser.fromJson(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Added trainer: ${trainer.name}',
    );

    return result;
  }

  @override
  Future<AdminUser> updateTrainer(AdminUser trainer) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    // Check if there's a new local photo to upload
    String? photoUrl = trainer.photoUrl;
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      photoUrl = await _uploadTrainerPhoto(photoUrl);
    }

    final fields = {
      'admin_email': admin.email,
      'admin_password': adminPassword,
      'trainer_email': trainer.email,
      'trainer_password': 'trainerpass',
      'trainer_name': trainer.name,
      'profile_description': trainer.profileDescription ?? '',
      'experience_years': (trainer.experienceYears ?? 0).toString(),
      'expertise': trainer.expertise?.join(', ') ?? '',
      'phone': trainer.phone ?? '',
      'location': trainer.location ?? '',
      'linkedin_url': trainer.linkedinUrl ?? '',
      'website_url': trainer.websiteUrl ?? '',
      'photo_url': photoUrl ?? '',
    };

    final result = await getIt<NetworkManager>().put<AdminUser>(
      path: '/admin/trainers',
      body: fields,
      converter: (json) => AdminUser.fromJson(json),
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Updated trainer: ${trainer.name}',
    );

    return result;
  }

  @override
  Future<void> removeTrainer(int id) async {
    final admin = await getIt<AdminAuthRepository>().getCurrentUser();
    if (admin == null) throw Exception('Admin not logged in');
    final adminPassword = await _getAdminPassword();

    final trainers = await getTrainers();
    final trainer = trainers.firstWhere((t) => t.id == id);

    // Delete photo if exists
    if (trainer.photoUrl != null && trainer.photoUrl!.isNotEmpty) {
      try {
        await getIt<FileUploadRepository>().deleteFile(trainer.photoUrl!);
      } catch (e) {
        print('Failed to delete trainer photo: $e');
      }
    }

    await getIt<NetworkManager>().delete(
      path: '/admin/trainers',
      body: {
        'admin_email': admin.email,
        'admin_password': adminPassword,
        'trainer_email': trainer.email,
        'trainer_password': 'trainerpass',
        'trainer_name': trainer.name,
      },
      converter: (json) => json,
    );

    getIt<ActivityRepository>().logActivity(
      user: admin.name,
      activity: 'Removed trainer: ${trainer.name}',
    );
  }
}
