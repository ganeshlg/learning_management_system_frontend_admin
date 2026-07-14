import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system_trainer/app/pages/dashboard/dashboard_page.dart';
import 'package:learning_management_system_trainer/app/widgets/common/loading_dialog.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/entities/course_status.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  return await getIt<CourseRepository>().getCourses();
});

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

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
                    'Course Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/courses/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: coursesAsync.when(
                  data: (courses) => _CoursesTable(courses: courses),
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
}

class _CoursesTable extends ConsumerStatefulWidget {
  final List<Course> courses;

  const _CoursesTable({required this.courses});

  @override
  ConsumerState<_CoursesTable> createState() => _CoursesTableState();
}

class _CoursesTableState extends ConsumerState<_CoursesTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                      columns: const [
                        DataColumn(label: Text('Thumbnail')),
                        DataColumn(label: Text('Course Title')),
                        DataColumn(label: Text('Instructor')),
                        DataColumn(label: Text('Price'), numeric: true),
                        DataColumn(label: Text('Duration'), numeric: true),
                        DataColumn(label: Text('Modules'), numeric: true),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: widget.courses.map((course) {
                        return DataRow(cells: [
                          DataCell(
                            Container(
                              width: 60,
                              height: 40,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                                image: course.thumbnailUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(course.thumbnailUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: course.thumbnailUrl == null
                                  ? const Icon(Icons.image, size: 20, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(
                                course.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(course.instructorName)),
                          DataCell(Text('₹${course.price.toStringAsFixed(0)}')),
                          DataCell(Text('${course.durationHours}h')),
                          DataCell(Text(course.modules.length.toString())),
                          DataCell(_StatusBadge(status: course.status)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => context.go('/courses/${course.id}'),
                                  tooltip: 'Edit Course',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Course'),
                                        content: Text('Are you sure you want to delete "${course.title}"? This will remove all associated modules and lessons.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      if (context.mounted) LoadingDialog.show(context, message: 'Deleting course...');
                                      try {
                                        await getIt<CourseRepository>().deleteCourse(course.id);
                                        ref.invalidate(coursesProvider);
                                        ref.invalidate(dashboardStatsProvider);
                                      } finally {
                                        if (context.mounted) LoadingDialog.hide(context);
                                      }
                                    }
                                  },
                                  tooltip: 'Delete Course',
                                ),
                                if (course.status == CourseStatus.draft)
                                  IconButton(
                                    icon: const Icon(Icons.publish, color: Colors.green, size: 20),
                                    onPressed: () async {
                                      LoadingDialog.show(context, message: 'Publishing course...');
                                      try {
                                        await getIt<CourseRepository>().publishCourse(course.id);
                                        ref.invalidate(coursesProvider);
                                        ref.invalidate(dashboardStatsProvider);
                                      } finally {
                                        if (context.mounted) LoadingDialog.hide(context);
                                      }
                                    },
                                    tooltip: 'Publish Course',
                                  ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CourseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case CourseStatus.published:
        color = Colors.green;
        break;
      case CourseStatus.draft:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
