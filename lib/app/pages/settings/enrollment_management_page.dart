import 'package:flutter/material.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/enrollment_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';

class EnrollmentManagementPage extends StatefulWidget {
  const EnrollmentManagementPage({super.key});

  @override
  State<EnrollmentManagementPage> createState() => _EnrollmentManagementPageState();
}

class _EnrollmentManagementPageState extends State<EnrollmentManagementPage> {
  final _enrollmentRepo = getIt<EnrollmentRepository>();
  final _courseRepo = getIt<CourseRepository>();

  List<Course> _courses = [];
  Course? _selectedCourse;
  List<AdminUser> _enrolledUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await _courseRepo.getCourses();
      setState(() {
        _courses = courses;
        if (_courses.isNotEmpty) {
          _selectedCourse = _courses.first;
          _loadEnrolledUsers();
        }
      });
    } catch (e) {
      _showError('Failed to load courses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEnrolledUsers() async {
    if (_selectedCourse == null) return;
    setState(() => _isLoading = true);
    try {
      final users = await _enrollmentRepo.getEnrolledUsers(_selectedCourse!.id);
      setState(() => _enrolledUsers = users);
    } catch (e) {
      _showError('Failed to load users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _addUser() async {
    final emailController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enroll User'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'User Email',
            hintText: 'user@example.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enroll'),
          ),
        ],
      ),
    );

    if (result == true && emailController.text.isNotEmpty && _selectedCourse != null) {
      setState(() => _isLoading = true);
      try {
        await _enrollmentRepo.addUserToCourse(
          email: emailController.text,
          courseId: _selectedCourse!.id,
        );
        _showSuccess('User enrolled successfully');
        _loadEnrolledUsers();
      } catch (e) {
        _showError('Failed to enroll user: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeUser(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove ${user.email} from this course?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedCourse != null) {
      setState(() => _isLoading = true);
      try {
        await _enrollmentRepo.removeUserFromCourse(
          email: user.email,
          courseId: _selectedCourse!.id,
        );
        _showSuccess('User removed successfully');
        _loadEnrolledUsers();
      } catch (e) {
        _showError('Failed to remove user: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Select Course: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<Course>(
                    isExpanded: true,
                    value: _selectedCourse,
                    items: _courses.map((course) {
                      return DropdownMenuItem(
                        value: course,
                        child: Text(course.title),
                      );
                    }).toList(),
                    onChanged: (course) {
                      setState(() {
                        _selectedCourse = course;
                        _loadEnrolledUsers();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _enrolledUsers.isEmpty
                    ? const Center(child: Text('No users enrolled in this course'))
                    : ListView.builder(
                        itemCount: _enrolledUsers.length,
                        itemBuilder: (context, index) {
                          final user = _enrolledUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_remove, color: Colors.red),
                              onPressed: () => _removeUser(user),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addUser,
        label: const Text('Enroll User'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
