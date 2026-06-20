import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    onPressed: () => _showAddTrainerDialog(context, ref),
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

  void _showAddTrainerDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Trainer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newTrainer = AdminUser(
                id: DateTime.now().millisecondsSinceEpoch,
                name: nameController.text,
                email: emailController.text,
                role: AdminRole.trainer,
              );
              await getIt<TrainerRepository>().addTrainer(newTrainer);
              ref.invalidate(trainersProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
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
              child: Text(trainer.name[0].toUpperCase()),
            ),
            title: Text(trainer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(trainer.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditTrainerDialog(context, ref, trainer),
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
                      await getIt<TrainerRepository>().removeTrainer(trainer.id);
                      ref.invalidate(trainersProvider);
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

  void _showEditTrainerDialog(BuildContext context, WidgetRef ref, AdminUser trainer) {
    final nameController = TextEditingController(text: trainer.name);
    final emailController = TextEditingController(text: trainer.email);
    AdminRole selectedRole = trainer.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Trainer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AdminRole>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                items: AdminRole.values.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role.name.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selectedRole = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updatedTrainer = trainer.copyWith(
                  name: nameController.text,
                  email: emailController.text,
                  role: selectedRole,
                );
                await getIt<TrainerRepository>().updateTrainer(updatedTrainer);
                ref.invalidate(trainersProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
