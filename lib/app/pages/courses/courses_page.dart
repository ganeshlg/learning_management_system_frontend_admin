import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class _CoursesTable extends ConsumerWidget {
  final List<Course> courses;

  const _CoursesTable({required this.courses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Thumbnail')),
              DataColumn(label: Text('Course Title')),
              DataColumn(label: Text('Instructor')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Modules')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: courses.map((course) {
              return DataRow(cells: [
                DataCell(
                  Container(
                    width: 50,
                    height: 30,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 16),
                  ),
                ),
                DataCell(Text(course.title)),
                DataCell(Text(course.instructorName)),
                DataCell(Text('\$${course.price}')),
                DataCell(Text(course.modules.length.toString())),
                DataCell(_StatusBadge(status: course.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => context.go('/courses/${course.id}'),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await getIt<CourseRepository>().deleteCourse(course.id);
                          ref.invalidate(coursesProvider);
                        },
                        tooltip: 'Delete',
                      ),
                      if (course.status == CourseStatus.draft)
                        IconButton(
                          icon: const Icon(Icons.publish, color: Colors.green),
                          onPressed: () async {
                            await getIt<CourseRepository>().publishCourse(course.id);
                            ref.invalidate(coursesProvider);
                          },
                          tooltip: 'Publish',
                        ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
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
      case CourseStatus.archived:
        color = Colors.grey;
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
