import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system_trainer/domain/entities/resource.dart';
import 'package:learning_management_system_trainer/domain/repositories/resource_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';

final resourcesProvider = FutureProvider.autoDispose<List<Resource>>((ref) async {
  return await getIt<ResourceRepository>().getResources();
});

class ResourcesPage extends ConsumerStatefulWidget {
  const ResourcesPage({super.key});

  @override
  ConsumerState<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends ConsumerState<ResourcesPage> {
  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourcesProvider);

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
                    'Resource Library',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(context),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Resource'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: resourcesAsync.when(
                  data: (resources) => _ResourcesGrid(resources: resources),
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

  void _showUploadDialog(BuildContext context) {
    String name = '';
    ResourceType selectedType = ResourceType.pdf;
    String? filePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload New Resource'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => name = v,
                decoration: const InputDecoration(labelText: 'Resource Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ResourceType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Resource Type', border: OutlineInputBorder()),
                items: ResourceType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setDialogState(() {
                      filePath = result.files.single.path;
                      if (name.isEmpty) {
                        name = result.files.single.name;
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          filePath ?? 'Select File',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (name.isNotEmpty && filePath != null) {
                  final newResource = Resource(
                    id: '',
                    name: name,
                    type: selectedType,
                    url: filePath!,
                    courseId: 'course-001', // Mock assignment
                  );
                  await getIt<ResourceRepository>().createResource(newResource);
                  ref.invalidate(resourcesProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourcesGrid extends StatelessWidget {
  final List<Resource> resources;

  const _ResourcesGrid({required this.resources});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getResourceIcon(resource.type, context),
                    const SizedBox(height: 12),
                    Text(
                      resource.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.type.name.toUpperCase(),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: const Icon(Icons.download, size: 20), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _getResourceIcon(ResourceType type, BuildContext context) {
    IconData icon;
    Color color;
    switch (type) {
      case ResourceType.pdf:
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case ResourceType.ppt:
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      case ResourceType.excel:
        icon = Icons.table_chart;
        color = Colors.green;
        break;
      case ResourceType.zip:
        icon = Icons.archive;
        color = Colors.blue;
        break;
      case ResourceType.video:
        icon = Icons.video_library;
        color = Colors.purple;
        break;
    }
    return Icon(icon, size: 48, color: color);
  }
}
