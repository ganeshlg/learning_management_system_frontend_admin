import 'package:learning_management_system_trainer/domain/entities/admin_role.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/entities/course_status.dart';
import 'package:learning_management_system_trainer/domain/entities/lesson.dart';
import 'package:learning_management_system_trainer/domain/entities/module.dart';
import 'package:learning_management_system_trainer/domain/entities/live_session.dart';

class MockData {
  static final superAdmin = AdminUser(
    id: 1,
    email: 'super@civilent.com',
    name: 'Super Admin',
    role: AdminRole.superAdmin,
    lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
  );

  static final trainer = AdminUser(
    id: 2,
    email: 'trainer@civilent.com',
    name: 'John Trainer',
    role: AdminRole.trainer,
    lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
  );

  static List<AdminUser> admins = [superAdmin, trainer];

  static List<Lesson> lessons = [
    Lesson(
      id: 'lesson-001',
      moduleId: 'module-001',
      title: 'Introduction to HTML',
      lessonType: LessonType.text,
      content: 'This is a lesson about HTML introduction',
      order: 0,
    ),
    Lesson(
      id: 'lesson-002',
      moduleId: 'module-001',
      title: 'HTML Tags & Attributes',
      lessonType: LessonType.text,
      content: 'Learn about HTML tags and attributes',
      order: 1,
    ),
    Lesson(
      id: 'lesson-003',
      moduleId: 'module-001',
      title: 'HTML Forms',
      lessonType: LessonType.text,
      content: 'Creating forms in HTML',
      order: 2,
    ),
    Lesson(
      id: 'lesson-004',
      moduleId: 'module-002',
      title: 'CSS Selectors',
      lessonType: LessonType.text,
      content: 'Understanding CSS Selectors',
      order: 0,
    ),
  ];

  static List<Module> modules = [
    Module(
      id: 'module-001',
      courseId: 'course-001',
      title: 'HTML Basics',
      description: 'Learn the fundamentals of HTML5.',
      order: 0,
      lessons: lessons.where((l) => l.moduleId == 'module-001').toList(),
    ),
    Module(
      id: 'module-002',
      courseId: 'course-001',
      title: 'CSS Styling',
      description: 'Master the art of styling web pages.',
      order: 1,
      lessons: lessons.where((l) => l.moduleId == 'module-002').toList(),
    ),
  ];

  static List<Course> courses = [
    Course(
      id: 'course-001',
      title: 'Web Development Fundamentals',
      description: 'Learn HTML, CSS, and JavaScript basics',
      price: 49.99,
      durationHours: 40,
      instructorName: 'John Doe',
      status: CourseStatus.published,
      modules: modules,
    ),
    Course(
      id: 'course-002',
      title: 'Entrepreneurship 101',
      description: 'The journey of building a startup.',
      price: 99.99,
      durationHours: 20,
      instructorName: 'Jane Smith',
      status: CourseStatus.draft,
      modules: [],
    ),
  ];

  static List<LiveSession> liveSessions = [
    LiveSession(
      id: 'session-1',
      title: 'Q&A: HTML Basics',
      courseId: 'course-001',
      startTime: DateTime.now().add(const Duration(days: 1)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
      meetingUrl: 'https://zoom.us/j/123456789',
    ),
  ];
}
