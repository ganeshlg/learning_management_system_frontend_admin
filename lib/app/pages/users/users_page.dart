import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system_trainer/app/widgets/common/loading_dialog.dart';
import 'package:learning_management_system_trainer/domain/entities/student_user.dart';
import 'package:learning_management_system_trainer/domain/repositories/student_repository.dart';
import 'package:learning_management_system_trainer/domain/entities/course.dart';
import 'package:learning_management_system_trainer/domain/repositories/course_repository.dart';
import 'package:learning_management_system_trainer/domain/repositories/enrollment_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';
import 'package:learning_management_system_trainer/domain/constants/AppConstants.dart';

final studentsProvider = FutureProvider.autoDispose<List<StudentUser>>((ref) async {
  return await getIt<StudentRepository>().getAllUsers();
});

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  return await getIt<CourseRepository>().getCourses();
});

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);

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
                    'User Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showUserDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: studentsAsync.when(
                  data: (users) {
                    final filteredUsers = users.where((u) =>
                        u.name.toLowerCase().contains(_searchQuery) ||
                        u.email.toLowerCase().contains(_searchQuery)).toList();
                    
                    if (filteredUsers.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    return Card(
                      child: ListView.separated(
                        itemCount: filteredUsers.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.passportPhotoUrl != null && user.passportPhotoUrl!.isNotEmpty
                                  ? NetworkImage(user.passportPhotoUrl!.startsWith('http')
                                      ? user.passportPhotoUrl!
                                      : '${AppConstants.baseUrl.replaceAll('/api', '')}/${user.passportPhotoUrl}')
                                  : null,
                              child: (user.passportPhotoUrl == null || user.passportPhotoUrl!.isEmpty)
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(user.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showUserDialog(user: user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(user),
                                ),
                              ],
                            ),
                            onTap: () => _showUserDetails(user),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetails(StudentUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem('Email', user.email),
                _detailItem('Password', user.password ?? 'N/A'),
                _detailItem('Current Course ID', user.courseId ?? 'N/A'),
                const Divider(),
                const Text('Enrolled Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                FutureBuilder<List<Course>>(
                  future: _getUserCourses(user),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading courses: ${snapshot.error}');
                    }
                    final courses = snapshot.data ?? [];
                    if (courses.isEmpty) {
                      return const Text('No courses enrolled');
                    }
                    return Column(
                      children: courses.map((c) => ListTile(
                        title: Text(c.title),
                        subtitle: Text('ID: ${c.id}'),
                        dense: true,
                      )).toList(),
                    );
                  },
                ),
                const Divider(),
                _detailItem('Full Name', user.fullName ?? 'N/A'),
                _detailItem('Mobile', user.mobileNumber ?? 'N/A'),
                _detailItem('Gender', user.gender ?? 'N/A'),
                _detailItem('DOB', user.dateOfBirth ?? 'N/A'),
                _detailItem('Address', user.address ?? 'N/A'),
                _detailItem('City/State/Pin', user.cityStatePin ?? 'N/A'),
                _detailItem('Emergency Contact', user.emergencyContact ?? 'N/A'),
                _detailItem('Qualification', user.educationalQualification ?? 'N/A'),
                _detailItem('University', user.collegeUniversity ?? 'N/A'),
                _detailItem('Graduation Year', user.yearOfGraduation ?? 'N/A'),
                _detailItem('Current Status', user.currentStatus ?? 'N/A'),
                _detailItem('Organization', user.currentOrganization ?? 'N/A'),
                _detailItem('Experience', user.totalExperience ?? 'N/A'),
                _detailItem('Business Name', user.businessName ?? 'N/A'),
                _detailItem('Areas of Interest', user.areasOfInterest ?? 'N/A'),
                _detailItem('Why join', user.whyJoinProgram ?? 'N/A'),
                _detailItem('Business Idea', user.businessIdea ?? 'N/A'),
                _detailItem('Skills to develop', user.skillsToDevelop ?? 'N/A'),
                _detailItem('How heard', user.howHeardAboutProgram ?? 'N/A'),
                _detailItem('Documents', user.documentsEnclosed ?? 'N/A'),
                _detailItem('Declaration', user.declaration ?? 'N/A'),
                _detailItem('Signature', user.signature ?? 'N/A'),
                _detailItem('Declaration Date', user.declarationDate ?? 'N/A'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<List<Course>> _getUserCourses(StudentUser user) async {
    final allCourses = await getIt<CourseRepository>().getCourses();
    final userCourses = <Course>[];
    for (var course in allCourses) {
      final enrolledUsers = await getIt<EnrollmentRepository>().getEnrolledUsers(course.id);
      if (enrolledUsers.any((u) => u.email == user.email)) {
        userCourses.add(course);
      }
    }
    return userCourses;
  }

  Future<void> _showUserDialog({StudentUser? user}) async {
    final coursesAsync = ref.read(coursesProvider);
    List<Course> availableCourses = coursesAsync.value ?? [];
    Course? selectedCourse;
    if (user?.courseId != null) {
      selectedCourse = availableCourses.cast<Course?>().firstWhere((c) => c?.id == user!.courseId, orElse: () => null);
    }

    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final passwordController = TextEditingController(text: user?.password);
    final fullNameController = TextEditingController(text: user?.fullName);
    final mobileController = TextEditingController(text: user?.mobileNumber);
    final photoUrlController = TextEditingController(text: user?.passportPhotoUrl);
    final dobController = TextEditingController(text: user?.dateOfBirth);
    final genderController = TextEditingController(text: user?.gender);
    final addressController = TextEditingController(text: user?.address);
    final cityStatePinController = TextEditingController(text: user?.cityStatePin);
    final emergencyContactController = TextEditingController(text: user?.emergencyContact);
    final qualificationController = TextEditingController(text: user?.educationalQualification);
    final universityController = TextEditingController(text: user?.collegeUniversity);
    final gradYearController = TextEditingController(text: user?.yearOfGraduation);
    final statusController = TextEditingController(text: user?.currentStatus);
    final orgController = TextEditingController(text: user?.currentOrganization);
    final experienceController = TextEditingController(text: user?.totalExperience);
    final businessNameController = TextEditingController(text: user?.businessName);
    final interestController = TextEditingController(text: user?.areasOfInterest);
    final whyJoinController = TextEditingController(text: user?.whyJoinProgram);
    final ideaController = TextEditingController(text: user?.businessIdea);
    final skillsController = TextEditingController(text: user?.skillsToDevelop);
    final howHeardController = TextEditingController(text: user?.howHeardAboutProgram);
    final docsController = TextEditingController(text: user?.documentsEnclosed);
    final declarationController = TextEditingController(text: user?.declaration);
    final signatureController = TextEditingController(text: user?.signature);
    final declarationDateController = TextEditingController(text: user?.declarationDate);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Account Information'),
                Row(
                  children: [
                    Expanded(child: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Username'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<Course>(
                        value: selectedCourse,
                        decoration: const InputDecoration(labelText: 'Enrolled Course'),
                        items: availableCourses.map((c) => DropdownMenuItem(value: c, child: Text(c.title))).toList(),
                        onChanged: (val) => selectedCourse = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionHeader('Personal Details'),
                Row(
                  children: [
                    Expanded(child: TextField(controller: fullNameController, decoration: const InputDecoration(labelText: 'Full Name'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: mobileController, decoration: const InputDecoration(labelText: 'Mobile Number'))),
                  ],
                ),
                TextField(controller: photoUrlController, decoration: const InputDecoration(labelText: 'Passport Photo URL')),
                Row(
                  children: [
                    Expanded(child: TextField(controller: dobController, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: genderController, decoration: const InputDecoration(labelText: 'Gender'))),
                  ],
                ),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                TextField(controller: cityStatePinController, decoration: const InputDecoration(labelText: 'City, State, Pin')),
                TextField(controller: emergencyContactController, decoration: const InputDecoration(labelText: 'Emergency Contact')),
                const SizedBox(height: 16),
                _sectionHeader('Education & Experience'),
                Row(
                  children: [
                    Expanded(child: TextField(controller: qualificationController, decoration: const InputDecoration(labelText: 'Educational Qualification'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: universityController, decoration: const InputDecoration(labelText: 'College/University'))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: gradYearController, decoration: const InputDecoration(labelText: 'Year of Graduation'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: experienceController, decoration: const InputDecoration(labelText: 'Total Experience'))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: statusController, decoration: const InputDecoration(labelText: 'Current Status'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: orgController, decoration: const InputDecoration(labelText: 'Current Organization'))),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionHeader('Program Details'),
                TextField(controller: businessNameController, decoration: const InputDecoration(labelText: 'Business Name')),
                TextField(controller: interestController, decoration: const InputDecoration(labelText: 'Areas of Interest')),
                TextField(controller: whyJoinController, maxLines: 2, decoration: const InputDecoration(labelText: 'Why join program?')),
                TextField(controller: ideaController, maxLines: 2, decoration: const InputDecoration(labelText: 'Business Idea')),
                TextField(controller: skillsController, maxLines: 2, decoration: const InputDecoration(labelText: 'Skills to develop')),
                TextField(controller: howHeardController, decoration: const InputDecoration(labelText: 'How heard about program')),
                TextField(controller: docsController, decoration: const InputDecoration(labelText: 'Documents Enclosed')),
                const SizedBox(height: 16),
                _sectionHeader('Declaration'),
                TextField(controller: declarationController, decoration: const InputDecoration(labelText: 'Declaration (true/false)')),
                Row(
                  children: [
                    Expanded(child: TextField(controller: signatureController, decoration: const InputDecoration(labelText: 'Signature'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: declarationDateController, decoration: const InputDecoration(labelText: 'Declaration Date'))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(user == null ? 'Create' : 'Update')),
        ],
      ),
    );

    if (result == true) {
      LoadingDialog.show(context, message: user == null ? 'Creating user...' : 'Updating user...');
      try {
        final student = (user ?? StudentUser(id: 0, name: '', email: '')).copyWith(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          courseId: selectedCourse?.id,
          fullName: fullNameController.text,
          mobileNumber: mobileController.text,
          passportPhotoUrl: photoUrlController.text,
          dateOfBirth: dobController.text,
          gender: genderController.text,
          address: addressController.text,
          cityStatePin: cityStatePinController.text,
          emergencyContact: emergencyContactController.text,
          educationalQualification: qualificationController.text,
          collegeUniversity: universityController.text,
          yearOfGraduation: gradYearController.text,
          currentStatus: statusController.text,
          currentOrganization: orgController.text,
          totalExperience: experienceController.text,
          businessName: businessNameController.text,
          areasOfInterest: interestController.text,
          whyJoinProgram: whyJoinController.text,
          businessIdea: ideaController.text,
          skillsToDevelop: skillsController.text,
          howHeardAboutProgram: howHeardController.text,
          documentsEnclosed: docsController.text,
          declaration: declarationController.text,
          signature: signatureController.text,
          declarationDate: declarationDateController.text,
        );

        if (user == null) {
          await getIt<StudentRepository>().createUser(student);
        } else {
          await getIt<StudentRepository>().updateUser(student);
        }
        ref.invalidate(studentsProvider);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) LoadingDialog.hide(context);
      }
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
      ),
    );
  }

  Future<void> _confirmDelete(StudentUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to permanently delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      LoadingDialog.show(context, message: 'Deleting user...');
      try {
        await getIt<StudentRepository>().deleteUser(user.id);
        ref.invalidate(studentsProvider);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) LoadingDialog.hide(context);
      }
    }
  }
}
