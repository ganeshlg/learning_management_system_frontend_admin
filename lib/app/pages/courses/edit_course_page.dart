import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_management_system_trainer/app/widgets/course/module_list_item.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/entities/module.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/module_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/lesson_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';
import 'package:reorderables/reorderables.dart';

import '../../../domain/entities/lesson.dart';

final courseDetailProvider = FutureProvider.family.autoDispose<Course?, String>((ref, id) async {
  return await getIt<CourseRepository>().getCourseById(id);
});

final courseModulesProvider = FutureProvider.family.autoDispose<List<Module>, String>((ref, courseId) async {
  return await getIt<ModuleRepository>().getModulesByCourseId(courseId);
});

class EditCoursePage extends ConsumerStatefulWidget {
  final String id;
  const EditCoursePage({super.key, required this.id});

  @override
  ConsumerState<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends ConsumerState<EditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  // final ScrollController _scrollController = ScrollController();
  String? _thumbnailUrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _initializeFields(Course course) {
    if (_initialized) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _titleController.text = course.title;
        _descriptionController.text = course.description;
        setState(() {
          _thumbnailUrl = course.thumbnailUrl;
          _initialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    // _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.id));
    final modulesAsync = ref.watch(courseModulesProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final course = await ref.read(courseDetailProvider(widget.id).future);
                  if (course != null) {
                    final updatedCourse = course.copyWith(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      thumbnailUrl: _thumbnailUrl,
                    );
                    
                    await getIt<CourseRepository>().updateCourse(updatedCourse);
                    ref.invalidate(courseDetailProvider(widget.id));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course updated successfully')),
                      );
                    }
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
      body: courseAsync.when(
        data: (course) {
          if (course == null) return const Center(child: Text('Course not found'));
          
          _initializeFields(course);

          return SingleChildScrollView(
            // controller: _scrollController,
            child: ScreenStabilizer(
              isForm: true,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseInfoCard(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Modules & Curriculum', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () => _showAddModuleDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Module'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    modulesAsync.when(
                      data: (modules) => _buildModuleList(modules),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 160,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: _thumbnailUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _thumbnailUrl == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Upload Thumbnail',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                    textAlign: TextAlign.center),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Course Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // In a real app, you would upload this to a server/storage
      setState(() {
        _thumbnailUrl = image.path; // Using path as local placeholder
      });
    }
  }

  Widget _buildModuleList(List<Module> modules) {
    return ReorderableColumn(
      key: const ValueKey('modules_reorderable_column'),
      // scrollController: _scrollController,
      onReorder: (oldIndex, newIndex) async {
        final updatedModules = List<Module>.from(modules);
        final item = updatedModules.removeAt(oldIndex);
        updatedModules.insert(newIndex, item);
        
        await getIt<ModuleRepository>().reorderModules(
          updatedModules.map((m) => m.id).toList(),
        );
        ref.invalidate(courseModulesProvider(widget.id));
      },
      children: modules.map((module) {
        return ModuleListItem(
          key: ValueKey(module.id),
          module: module,
          onEdit: () => _showEditModuleDialog(context, module),
          onDelete: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Module'),
                content: Text('Are you sure you want to delete "${module.title}" and all its lessons?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await getIt<ModuleRepository>().deleteModule(module.id);
              ref.invalidate(courseModulesProvider(widget.id));
            }
          },
          // scrollController: _scrollController,
          onLessonsReordered: (lessonIds) async {
            await getIt<LessonRepository>().reorderLessons(lessonIds);
            ref.invalidate(courseModulesProvider(widget.id));
          },
          onAddLesson: (moduleId) => _showAddLessonDialog(context, moduleId),
          onEditLesson: (lesson) => _showEditLessonDialog(context, lesson),
          onDeleteLesson: (lessonId) async {
            await getIt<LessonRepository>().deleteLesson(lessonId);
            ref.invalidate(courseModulesProvider(widget.id));
          },
        );
      }).toList(),
    );
  }

  void _showEditModuleDialog(BuildContext context, Module module) {
    final titleController = TextEditingController(text: module.title);
    final descriptionController = TextEditingController(text: module.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Module'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Module Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await getIt<ModuleRepository>().updateModule(
                  module.copyWith(
                    title: titleController.text,
                    description: descriptionController.text,
                  ),
                );
                ref.invalidate(courseModulesProvider(widget.id));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditLessonDialog(BuildContext context, Lesson lesson) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: lesson.title);
    final videoUrlController = TextEditingController(text: lesson.videoUrl);
    final contentController = TextEditingController(text: lesson.content);
    LessonType selectedType = lesson.lessonType;
    List<LessonResource> currentResources = List.from(lesson.resources);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Lesson'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Lesson Title'),
                    validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LessonType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Primary Lesson Type'),
                    items: LessonType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == LessonType.video)
                    TextFormField(
                      controller: videoUrlController,
                      decoration: const InputDecoration(labelText: 'Video URL', hintText: 'https://youtube.com/...'),
                      validator: (v) {
                        if (selectedType == LessonType.video && (v == null || v.isEmpty)) {
                          return 'Video URL is required';
                        }
                        if (v != null && v.isNotEmpty && !Uri.parse(v).isAbsolute) {
                          return 'Enter a valid URL';
                        }
                        return null;
                      },
                    ),
                  if (selectedType == LessonType.text)
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Notes / Content'),
                      maxLines: 5,
                      validator: (v) => selectedType == LessonType.text && (v == null || v.isEmpty) ? 'Content is required' : null,
                    ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resources', style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _showAddResourceDialog(context, (newResource) {
                          setDialogState(() => currentResources.add(newResource));
                        }),
                      ),
                    ],
                  ),
                  ...currentResources.map((res) => ListTile(
                        dense: true,
                        leading: Icon(_getResourceIcon(res.fileType)),
                        title: Text(res.title),
                        subtitle: Text(res.fileType.toUpperCase()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => setDialogState(() => currentResources.remove(res)),
                        ),
                      )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedLesson = lesson.copyWith(
                    title: titleController.text,
                    lessonType: selectedType,
                    videoUrl: videoUrlController.text,
                    content: contentController.text,
                    resources: currentResources,
                  );
                  await getIt<LessonRepository>().updateLesson(updatedLesson);
                  ref.invalidate(courseModulesProvider(widget.id));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context, String moduleId) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final videoUrlController = TextEditingController();
    final contentController = TextEditingController();
    LessonType selectedType = LessonType.video;
    List<LessonResource> currentResources = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Lesson'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Lesson Title'),
                    validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LessonType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Primary Lesson Type'),
                    items: LessonType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == LessonType.video)
                    TextFormField(
                      controller: videoUrlController,
                      decoration: const InputDecoration(labelText: 'Video URL', hintText: 'https://youtube.com/...'),
                      validator: (v) {
                        if (selectedType == LessonType.video && (v == null || v.isEmpty)) {
                          return 'Video URL is required';
                        }
                        if (v != null && v.isNotEmpty && !Uri.parse(v).isAbsolute) {
                          return 'Enter a valid URL';
                        }
                        return null;
                      },
                    ),
                  if (selectedType == LessonType.text)
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Notes / Content'),
                      maxLines: 5,
                      validator: (v) => selectedType == LessonType.text && (v == null || v.isEmpty) ? 'Content is required' : null,
                    ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resources', style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _showAddResourceDialog(context, (newResource) {
                          setDialogState(() => currentResources.add(newResource));
                        }),
                      ),
                    ],
                  ),
                  ...currentResources.map((res) => ListTile(
                        dense: true,
                        leading: Icon(_getResourceIcon(res.fileType)),
                        title: Text(res.title),
                        subtitle: Text(res.fileType.toUpperCase()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => setDialogState(() => currentResources.remove(res)),
                        ),
                      )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newLesson = Lesson(
                    id: '',
                    moduleId: moduleId,
                    title: titleController.text,
                    lessonType: selectedType,
                    videoUrl: videoUrlController.text,
                    content: contentController.text,
                    resources: currentResources,
                    order: 0,
                  );
                  await getIt<LessonRepository>().createLesson(newLesson);
                  ref.invalidate(courseModulesProvider(widget.id));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddResourceDialog(BuildContext context, Function(LessonResource) onAdded) {
    final titleController = TextEditingController();
    String? selectedPath;
    String selectedFileType = 'pdf';
    final fileTypes = ['pdf', 'excel', 'ppt', 'doc', 'link', 'video'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Resource'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Resource Title'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedFileType,
                decoration: const InputDecoration(labelText: 'File Type'),
                items: fileTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selectedFileType = value);
                },
              ),
              const SizedBox(height: 16),
              if (selectedFileType == 'link')
                TextField(
                  onChanged: (value) => selectedPath = value,
                  decoration: const InputDecoration(labelText: 'URL (https://...)'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setDialogState(() {
                        selectedPath = result.files.single.name;
                        if (titleController.text.isEmpty) {
                          titleController.text = result.files.single.name;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedPath ?? 'Choose File'),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedPath != null) {
                  onAdded(LessonResource(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    url: selectedPath!,
                    fileType: selectedFileType,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getResourceIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'excel':
        return Icons.table_chart;
      case 'ppt':
        return Icons.slideshow;
      case 'doc':
        return Icons.description;
      case 'link':
        return Icons.link;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showAddModuleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Module'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Module Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await getIt<ModuleRepository>().createModule(
                  Module(
                    id: '',
                    courseId: widget.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    order: 0,
                    lessons: [],
                  ),
                );
                ref.invalidate(courseModulesProvider(widget.id));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
