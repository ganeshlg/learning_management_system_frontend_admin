import 'package:flutter/material.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_user.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/enrollment_repository.dart';
import 'package:learning_management_system_trainer/domain/entities/student_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/student_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';

class EnrollmentManagementPage extends StatefulWidget {
  const EnrollmentManagementPage({super.key});

  @override
  State<EnrollmentManagementPage> createState() => _EnrollmentManagementPageState();
}

class _EnrollmentManagementPageState extends State<EnrollmentManagementPage> {
  final _enrollmentRepo = getIt<EnrollmentRepository>();
  final _courseRepo = getIt<CourseRepository>();
  final _studentRepo = getIt<StudentRepository>();

  List<Course> _courses = [];
  Course? _selectedCourse;
  List<AdminUser> _enrolledUsers = [];
  List<StudentUser> _allStudents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final courses = await _courseRepo.getCourses();
      final students = await _studentRepo.getAllUsers();
      setState(() {
        _courses = courses;
        _allStudents = students;
        if (_courses.isNotEmpty) {
          _selectedCourse = _courses.first;
          _loadEnrolledUsers();
        }
      });
    } catch (e) {
      _showError('Failed to load data: $e');
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
    if (_selectedCourse == null) return;

    final enrolledEmails = _enrolledUsers.map((u) => u.email).toSet();
    final availableStudents = _allStudents.where((s) => !enrolledEmails.contains(s.email)).toList();

    if (availableStudents.isEmpty) {
      _showError('No more users available to enroll');
      return;
    }

    StudentUser? selectedStudent;
    String? selectedPaymentPlan = 'One-Time';
    final paidInstallmentsController = TextEditingController(text: '1');
    String searchQuery = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = availableStudents.where((s) =>
            s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            s.email.toLowerCase().contains(searchQuery.toLowerCase())
          ).toList();

          return AlertDialog(
            title: const Text('Enroll User'),
            content: SizedBox(
              width: 500,
              height: 550,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) => setDialogState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final student = filtered[index];
                          final isSelected = selectedStudent?.email == student.email;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.blue.withOpacity(0.1),
                            leading: CircleAvatar(child: Text(student.name[0])),
                            title: Text(student.name),
                            subtitle: Text(student.email),
                            onTap: () => setDialogState(() => selectedStudent = student),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPaymentPlan,
                          decoration: const InputDecoration(
                            labelText: 'Payment Plan',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'One-Time', child: Text('One-Time')),
                            DropdownMenuItem(value: 'Two-Installment', child: Text('Two-Installment')),
                            DropdownMenuItem(value: 'Three-Installment', child: Text('Three-Installment')),
                          ],
                          onChanged: (val) => setDialogState(() => selectedPaymentPlan = val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: paidInstallmentsController,
                          decoration: const InputDecoration(
                            labelText: 'Paid Installments',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: selectedStudent == null ? null : () => Navigator.pop(context, true),
                child: const Text('Enroll'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && selectedStudent != null) {
      setState(() => _isLoading = true);
      try {
        await _enrollmentRepo.addUserToCourse(
          email: selectedStudent!.email,
          courseId: _selectedCourse!.id,
          paymentPlan: selectedPaymentPlan,
          paidInstallments: int.tryParse(paidInstallmentsController.text) ?? 1,
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
