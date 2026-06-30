import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_management_system_trainer/app/widgets/common/loading_dialog.dart';
import 'package:learning_management_system_trainer/app/widgets/course/module_list_item.dart';
import 'package:learning_management_system_trainer/domain/constants/AppConstants.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/entities/module.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/module_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/file_upload_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/lesson_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';
import 'package:reorderables/reorderables.dart';
import '../../../domain/entities/course_status.dart';
import '../../../domain/entities/lesson.dart';
import '../dashboard/dashboard_page.dart';
import 'courses_page.dart';

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
  late TextEditingController _instructorController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _metaTitleController;
  late TextEditingController _metaDescriptionController;
  String? _thumbnailUrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _instructorController = TextEditingController();
    _priceController = TextEditingController();
    _durationController = TextEditingController();
    _metaTitleController = TextEditingController();
    _metaDescriptionController = TextEditingController();
  }

  void _initializeFields(Course course) {
    if (_initialized) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _titleController.text = course.title;
        _descriptionController.text = course.description;
        _instructorController.text = course.instructorName;
        _priceController.text = course.price.toString();
        _durationController.text = course.durationHours.toString();
        _metaTitleController.text = course.metaTitle ?? '';
        _metaDescriptionController.text = course.metaDescription ?? '';
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
    _instructorController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
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
          courseAsync.when(
            data: (course) {
              if (course == null) return const SizedBox.shrink();
              return Row(
                children: [
                  if (course.status == CourseStatus.draft)
                    TextButton.icon(
                      onPressed: () async {
                        LoadingDialog.show(context, message: 'Publishing course...');
                        try {
                          await getIt<CourseRepository>().publishCourse(widget.id);
                          ref.invalidate(courseDetailProvider(widget.id));
                          ref.invalidate(coursesProvider);
                          ref.invalidate(dashboardStatsProvider);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Course published successfully')),
                            );
                          }
                        } finally {
                          if (context.mounted) LoadingDialog.hide(context);
                        }
                      },
                      icon: const Icon(Icons.publish, color: Colors.green),
                      label: const Text('Publish', style: TextStyle(color: Colors.green)),
                    )
                  else
                    TextButton.icon(
                      onPressed: () async {
                        LoadingDialog.show(context, message: 'Unpublishing course...');
                        try {
                          await getIt<CourseRepository>().unpublishCourse(widget.id);
                          ref.invalidate(courseDetailProvider(widget.id));
                          ref.invalidate(coursesProvider);
                          ref.invalidate(dashboardStatsProvider);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Course unpublished successfully')),
                            );
                          }
                        } finally {
                          if (context.mounted) LoadingDialog.hide(context);
                        }
                      },
                      icon: const Icon(Icons.unpublished, color: Colors.orange),
                      label: const Text('Unpublish', style: TextStyle(color: Colors.orange)),
                    ),
                  const SizedBox(width: 8),
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
                              instructorName: _instructorController.text,
                              price: double.tryParse(_priceController.text) ?? 0.0,
                              durationHours: int.tryParse(_durationController.text) ?? 0,
                              thumbnailUrl: _thumbnailUrl,
                              metaTitle: _metaTitleController.text,
                              metaDescription: _metaDescriptionController.text,
                            );

                            if (context.mounted) LoadingDialog.show(context, message: 'Saving changes...');
                            try {
                              await getIt<CourseRepository>().updateCourse(updatedCourse);
                              ref.invalidate(courseDetailProvider(widget.id));
                              // Also invalidate the courses list and dashboard stats to ensure they reflect changes
                              ref.invalidate(coursesProvider);
                              ref.invalidate(dashboardStatsProvider);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Course updated successfully')),
                                );
                              }
                            } finally {
                              if (context.mounted) LoadingDialog.hide(context);
                            }
                          }
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _instructorController,
                                decoration: const InputDecoration(
                                  labelText: 'Instructor Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  prefixText: '₹ ',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                decoration: const InputDecoration(
                                  labelText: 'Duration (Hours)',
                                  suffixText: ' hrs',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
      LoadingDialog.show(context, message: 'Uploading thumbnail...');
      try {
        final bytes = await image.readAsBytes();
        final uploadPath = await getIt<FileUploadRepository>().uploadBytes(
          bytes,
          image.name,
          folder: 'course_thumbnails',
        );
        final url = AppConstants.baseUrl + (uploadPath.startsWith('/') ? uploadPath : '/$uploadPath');

        setState(() {
          _thumbnailUrl = url;
        });

        // Automatically update course details with new thumbnail
        final course = await ref.read(courseDetailProvider(widget.id).future);
        if (course != null) {
          final updatedCourse = course.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            thumbnailUrl: url,
          );
          await getIt<CourseRepository>().updateCourse(updatedCourse);
          ref.invalidate(courseDetailProvider(widget.id));
          ref.invalidate(coursesProvider);
          ref.invalidate(dashboardStatsProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        if (context.mounted) LoadingDialog.hide(context);
      }
    }
  }

  Widget _buildModuleList(List<Module> modules) {
    return ReorderableColumn(
      key: const ValueKey('modules_reorderable_column'),
      onReorder: (oldIndex, newIndex) async {
        final updatedModules = List<Module>.from(modules);
        final item = updatedModules.removeAt(oldIndex);
        updatedModules.insert(newIndex, item);
        
        LoadingDialog.show(context, message: 'Reordering modules...');
        try {
          await getIt<ModuleRepository>().reorderModules(
            updatedModules.map((m) => m.id).toList(),
          );
          ref.invalidate(courseModulesProvider(widget.id));
        } finally {
          if (context.mounted) LoadingDialog.hide(context);
        }
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
              if (context.mounted) LoadingDialog.show(context, message: 'Deleting module...');
              try {
                await getIt<ModuleRepository>().deleteModule(module.id);
                ref.invalidate(courseModulesProvider(widget.id));
              } finally {
                if (context.mounted) LoadingDialog.hide(context);
              }
            }
          },
          onLessonsReordered: (lessonIds) async {
            LoadingDialog.show(context, message: 'Reordering lessons...');
            try {
              await getIt<LessonRepository>().reorderLessons(lessonIds);
              ref.invalidate(courseModulesProvider(widget.id));
            } finally {
              if (context.mounted) LoadingDialog.hide(context);
            }
          },
          onAddLesson: (moduleId) => _showAddLessonDialog(context, moduleId),
          onEditLesson: (lesson) => _showEditLessonDialog(context, lesson),
          onDeleteLesson: (lessonId) async {
            LoadingDialog.show(context, message: 'Deleting lesson...');
            try {
              await getIt<LessonRepository>().deleteLesson(lessonId);
              ref.invalidate(courseModulesProvider(widget.id));
            } finally {
              if (context.mounted) LoadingDialog.hide(context);
            }
          },
        );
      }).toList(),
    );
  }

  void _showEditModuleDialog(BuildContext context, Module module) {
    final titleController = TextEditingController(text: module.title);
    final descriptionController = TextEditingController(text: module.description);
    final videoUrlController = TextEditingController(text: module.videoUrl);
    final liveLinkController = TextEditingController(text: module.liveLink);
    final recordedVideoUrlController = TextEditingController(text: module.recordedVideoUrl);
    ModuleType selectedType = module.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Module'),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 16),
                DropdownButtonFormField<ModuleType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Module Type'),
                  items: ModuleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == ModuleType.recorded ? 'Pre-recorded' : 'Live Session'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (selectedType == ModuleType.recorded)
                  TextField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Video URL',
                      hintText: 'https://youtube.com/...',
                    ),
                  )
                else ...[
                  TextField(
                    controller: liveLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Live Link (Zoom/GMeet)',
                      hintText: 'https://zoom.us/j/...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: recordedVideoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Recorded Session Video URL',
                      hintText: 'https://youtube.com/...',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  LoadingDialog.show(context, message: 'Saving module...');
                  try {
                    await getIt<ModuleRepository>().updateModule(
                      module.copyWith(
                        title: titleController.text,
                        description: descriptionController.text,
                        type: selectedType,
                        videoUrl: selectedType == ModuleType.recorded ? videoUrlController.text : null,
                        liveLink: selectedType == ModuleType.live ? liveLinkController.text : null,
                        recordedVideoUrl: selectedType == ModuleType.live ? recordedVideoUrlController.text : null,
                      ),
                    );
                    ref.invalidate(courseModulesProvider(widget.id));
                  } finally {
                    if (context.mounted) LoadingDialog.hide(context);
                  }
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

  void _showEditLessonDialog(BuildContext context, Lesson lesson) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: lesson.title);
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
                    initialValue: selectedType,
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
                    content: contentController.text,
                    resources: currentResources,
                  );
                  LoadingDialog.show(context, message: 'Saving lesson...');
                  try {
                    await getIt<LessonRepository>().updateLesson(updatedLesson);
                    ref.invalidate(courseModulesProvider(widget.id));
                  } finally {
                    if (context.mounted) LoadingDialog.hide(context);
                  }
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
    final contentController = TextEditingController();
    LessonType selectedType = LessonType.text;
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
                    initialValue: selectedType,
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
                    id: "${widget.id}::$moduleId::${List.generate(10, (_) => Random().nextInt(10)).join()}",
                    moduleId: moduleId,
                    title: titleController.text,
                    lessonType: selectedType,
                    content: contentController.text,
                    resources: currentResources,
                    order: 0,
                  );
                  LoadingDialog.show(context, message: 'Creating lesson...');
                  try {
                    await getIt<LessonRepository>().createLesson(newLesson);
                    ref.invalidate(courseModulesProvider(widget.id));
                  } finally {
                    if (context.mounted) LoadingDialog.hide(context);
                  }
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
                initialValue: selectedFileType,
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
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      withData: true, // Required for web to get bytes
                    );
                    if (result != null) {
                      if (context.mounted) LoadingDialog.show(context, message: 'Uploading file...');
                      try {
                        final fileBytes = result.files.single.bytes;
                        if (fileBytes != null) {
                          final uploadPath = await getIt<FileUploadRepository>().uploadBytes(
                            fileBytes,
                            result.files.single.name,
                            folder: 'lesson_resources',
                          );
                          final url = AppConstants.baseUrl + (uploadPath.startsWith('/') ? uploadPath : '/$uploadPath');

                          setDialogState(() {
                            selectedPath = url;
                            if (titleController.text.isEmpty) {
                              titleController.text = result.files.single.name;
                            }
                          });
                        } else {
                          throw Exception('Failed to load file bytes');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Upload failed: $e')),
                          );
                        }
                      } finally {
                        if (context.mounted) LoadingDialog.hide(context);
                      }
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedPath != null ? 'File Uploaded' : 'Choose File'),
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
    final videoUrlController = TextEditingController();
    final liveLinkController = TextEditingController();
    final recordedVideoUrlController = TextEditingController();
    ModuleType selectedType = ModuleType.recorded;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Module'),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 16),
                DropdownButtonFormField<ModuleType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Module Type'),
                  items: ModuleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == ModuleType.recorded ? 'Pre-recorded' : 'Live Session'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (selectedType == ModuleType.recorded)
                  TextField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Video URL',
                      hintText: 'https://youtube.com/...',
                    ),
                  )
                else ...[
                  TextField(
                    controller: liveLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Live Link (Zoom/GMeet)',
                      hintText: 'https://zoom.us/j/...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: recordedVideoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Recorded Session Video URL',
                      hintText: 'https://youtube.com/...',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  LoadingDialog.show(context, message: 'Creating module...');
                  try {
                    await getIt<ModuleRepository>().createModule(
                      Module(
                        id: "${widget.id}::${List.generate(10, (_) => Random().nextInt(10)).join()}",
                        courseId: widget.id,
                        title: titleController.text,
                        description: descriptionController.text,
                        type: selectedType,
                        videoUrl: selectedType == ModuleType.recorded ? videoUrlController.text : null,
                        liveLink: selectedType == ModuleType.live ? liveLinkController.text : null,
                        recordedVideoUrl: selectedType == ModuleType.live ? recordedVideoUrlController.text : null,
                        order: 0,
                        lessons: [],
                      ),
                    );
                    ref.invalidate(courseModulesProvider(widget.id));
                  } finally {
                    if (context.mounted) LoadingDialog.hide(context);
                  }
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
}
