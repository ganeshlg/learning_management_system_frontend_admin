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

  // Payment module configurations
  final int singlePayModules;
  final int twoPayFirstModules;
  final int twoPaySecondModules;
  final int threePayFirstModules;
  final int threePaySecondModules;
  final int threePayThirdModules;

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
    this.singlePayModules = 0,
    this.twoPayFirstModules = 0,
    this.twoPaySecondModules = 0,
    this.threePayFirstModules = 0,
    this.threePaySecondModules = 0,
    this.threePayThirdModules = 0,
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
    int? singlePayModules,
    int? twoPayFirstModules,
    int? twoPaySecondModules,
    int? threePayFirstModules,
    int? threePaySecondModules,
    int? threePayThirdModules,
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
      singlePayModules: singlePayModules ?? this.singlePayModules,
      twoPayFirstModules: twoPayFirstModules ?? this.twoPayFirstModules,
      twoPaySecondModules: twoPaySecondModules ?? this.twoPaySecondModules,
      threePayFirstModules: threePayFirstModules ?? this.threePayFirstModules,
      threePaySecondModules: threePaySecondModules ?? this.threePaySecondModules,
      threePayThirdModules: threePayThirdModules ?? this.threePayThirdModules,
    );
  }
}
