import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_management_system_trainer/app/widgets/common/loading_dialog.dart';
import 'package:learning_management_system_trainer/domain/constants/AppConstants.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_role.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/trainer_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';

final trainersProvider = FutureProvider.autoDispose<List<AdminUser>>((ref) async {
  return await getIt<TrainerRepository>().getTrainers();
});

class TrainersPage extends ConsumerWidget {
  const TrainersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainersAsync = ref.watch(trainersProvider);

    return Scaffold(
      body: ScreenStabilizer(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trainer Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showTrainerFormDialog(context, ref),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Trainer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: trainersAsync.when(
                  data: (trainers) => _TrainersTable(trainers: trainers),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrainerFormDialog(BuildContext context, WidgetRef ref, {AdminUser? trainer}) {
    final isEditing = trainer != null;
    final nameController = TextEditingController(text: trainer?.name);
    final emailController = TextEditingController(text: trainer?.email);
    final descriptionController = TextEditingController(text: trainer?.profileDescription);
    final experienceController = TextEditingController(text: trainer?.experienceYears?.toString());
    final expertiseController = TextEditingController(text: trainer?.expertise?.join(', '));
    final phoneController = TextEditingController(text: trainer?.phone);
    final locationController = TextEditingController(text: trainer?.location);
    final linkedinController = TextEditingController(text: trainer?.linkedinUrl);
    final websiteController = TextEditingController(text: trainer?.websiteUrl);
    String? localPhotoPath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Trainer' : 'Add New Trainer'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final photo = await picker.pickImage(source: ImageSource.gallery);
                      if (photo != null) {
                        setDialogState(() => localPhotoPath = photo.path);
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: localPhotoPath != null 
                          ? (kIsWeb ? NetworkImage(localPhotoPath!) : FileImage(io.File(localPhotoPath!)) as ImageProvider)
                          : (trainer?.photoUrl != null ? NetworkImage(trainer!.photoUrl!) : null),
                      child: localPhotoPath == null && trainer?.photoUrl == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                    enabled: !isEditing,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(labelText: 'Experience (Years)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: expertiseController,
                    decoration: const InputDecoration(labelText: 'Expertise (Comma separated)', border: OutlineInputBorder(), hintText: 'PHP, Laravel, MySQL'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Profile Description', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: linkedinController,
                    decoration: const InputDecoration(labelText: 'LinkedIn URL', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(labelText: 'Website URL', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final expertiseList = expertiseController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                
                final updatedTrainer = (trainer ?? AdminUser(
                  id: 0,
                  name: '',
                  email: '',
                  role: AdminRole.trainer,
                )).copyWith(
                  name: nameController.text,
                  email: emailController.text,
                  profileDescription: descriptionController.text,
                  experienceYears: int.tryParse(experienceController.text),
                  expertise: expertiseList,
                  phone: phoneController.text,
                  location: locationController.text,
                  linkedinUrl: linkedinController.text,
                  websiteUrl: websiteController.text,
                  photoUrl: localPhotoPath ?? trainer?.photoUrl,
                );

                LoadingDialog.show(context, message: isEditing ? 'Saving changes...' : 'Adding trainer...');
                try {
                  if (isEditing) {
                    await getIt<TrainerRepository>().updateTrainer(updatedTrainer);
                  } else {
                    await getIt<TrainerRepository>().addTrainer(updatedTrainer);
                  }
                  ref.invalidate(trainersProvider);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                } finally {
                  if (context.mounted) LoadingDialog.hide(context);
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainersTable extends ConsumerWidget {
  final List<AdminUser> trainers;

  const _TrainersTable({required this.trainers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListView.separated(
        itemCount: trainers.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final trainer = trainers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              backgroundImage: trainer.photoUrl != null ? NetworkImage("${AppConstants.baseUrl}/${trainer.photoUrl!}") : null,
              child: trainer.photoUrl == null ? Text(trainer.name[0].toUpperCase()) : null,
            ),
            title: Text(trainer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.email),
                if (trainer.expertise != null && trainer.expertise!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Wrap(
                      spacing: 4,
                      children: trainer.expertise!.map((e) => Chip(
                        label: Text(e, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => const TrainersPage()._showTrainerFormDialog(context, ref, trainer: trainer),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Trainer'),
                        content: Text('Are you sure you want to remove ${trainer.name}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      if (context.mounted) LoadingDialog.show(context, message: 'Removing trainer...');
                      try {
                        await getIt<TrainerRepository>().removeTrainer(trainer.id);
                        ref.invalidate(trainersProvider);
                      } finally {
                        if (context.mounted) LoadingDialog.hide(context);
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
