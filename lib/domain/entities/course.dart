import 'package:learning_management_system_trainer/domain/entities/course_status.dart';
import 'package:learning_management_system_trainer/domain/entities/module.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final double price;
  final int durationHours;
  final String instructorName;
  final String? metaTitle;
  final String? metaDescription;
  final CourseStatus status;
  final List<Module> modules;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.price,
    required this.durationHours,
    required this.instructorName,
    this.metaTitle,
    this.metaDescription,
    required this.status,
    this.modules = const [],
  });

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    double? price,
    int? durationHours,
    String? instructorName,
    String? metaTitle,
    String? metaDescription,
    CourseStatus? status,
    List<Module>? modules,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      price: price ?? this.price,
      durationHours: durationHours ?? this.durationHours,
      instructorName: instructorName ?? this.instructorName,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      status: status ?? this.status,
      modules: modules ?? this.modules,
    );
  }
}
