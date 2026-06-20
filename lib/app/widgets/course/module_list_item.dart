import 'package:flutter/material.dart';
import 'package:learning_management_system_trainer/domain/entities/module.dart';
import 'package:learning_management_system_trainer/domain/entities/lesson.dart';
import 'package:reorderables/reorderables.dart';

class ModuleListItem extends StatefulWidget {
  final Module module;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ScrollController? scrollController;
  final Function(List<String> lessonIds)? onLessonsReordered;
  final Function(String moduleId)? onAddLesson;
  final Function(Lesson lesson)? onEditLesson;
  final Function(String lessonId)? onDeleteLesson;

  const ModuleListItem({
    super.key,
    required this.module,
    required this.onEdit,
    required this.onDelete,
    this.scrollController,
    this.onLessonsReordered,
    this.onAddLesson,
    this.onEditLesson,
    this.onDeleteLesson,
  });

  @override
  State<ModuleListItem> createState() => _ModuleListItemState();
}

class _ModuleListItemState extends State<ModuleListItem> {
  bool _isExpanded = false;
  final ScrollController _innerScrollController = ScrollController();

  @override
  void dispose() {
    _innerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Text(
              widget.module.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${widget.module.lessons.length} Lessons'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: widget.onEdit),
                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: widget.onDelete),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ReorderableColumn(
                    key: ValueKey('lessons_reorderable_${widget.module.id}'),
                    scrollController: _innerScrollController,
                    onReorder: (oldIndex, newIndex) {
                      final updatedLessons = List<Lesson>.from(widget.module.lessons);
                      final item = updatedLessons.removeAt(oldIndex);
                      updatedLessons.insert(newIndex, item);
                      widget.onLessonsReordered?.call(
                        updatedLessons.map((l) => l.id).toList(),
                      );
                    },
                    children: widget.module.lessons.map((lesson) {
                      return _LessonTile(
                        key: ValueKey(lesson.id),
                        lesson: lesson,
                        onEdit: () => widget.onEditLesson?.call(lesson),
                        onDelete: () => widget.onDeleteLesson?.call(lesson.id),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => widget.onAddLesson?.call(widget.module.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Lesson'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LessonTile({super.key, required this.lesson, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (lesson.lessonType) {
      case LessonType.video:
        icon = Icons.play_circle_outline;
        break;
      case LessonType.text:
        icon = Icons.notes;
        break;
      case LessonType.resource:
        icon = Icons.attachment;
        break;
      case LessonType.assignment:
        icon = Icons.assignment;
        break;
      case LessonType.quiz:
        icon = Icons.quiz;
        break;
      case LessonType.liveSession:
        icon = Icons.live_tv;
        break;
    }

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(lesson.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Lesson'),
                  content: Text('Are you sure you want to delete "${lesson.title}"?'),
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
                onDelete();
              }
            },
          ),
          const Icon(Icons.drag_indicator, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
