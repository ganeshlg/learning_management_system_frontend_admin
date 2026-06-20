import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/module.dart';
import 'package:learning_management_system_trainer/domain/repositories/module_repository.dart';

class MockModuleRepository implements ModuleRepository {
  @override
  Future<List<Module>> getModulesByCourseId(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.modules.where((m) => m.courseId == courseId).toList();
  }

  @override
  Future<Module> createModule(Module module) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newModule = Module(
      id: 'module-${MockData.modules.length + 1}',
      courseId: module.courseId,
      title: module.title,
      description: module.description,
      videoUrl: module.videoUrl,
      order: module.order,
      lessons: [],
    );
    MockData.modules.add(newModule);
    return newModule;
  }

  @override
  Future<Module> updateModule(Module module) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = MockData.modules.indexWhere((m) => m.id == module.id);
    if (index != -1) {
      MockData.modules[index] = module;
    }
    return module;
  }

  @override
  Future<void> deleteModule(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.modules.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> reorderModules(List<String> moduleIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < moduleIds.length; i++) {
      final index = MockData.modules.indexWhere((m) => m.id == moduleIds[i]);
      if (index != -1) {
        final module = MockData.modules[index];
        MockData.modules[index] = Module(
          id: module.id,
          courseId: module.courseId,
          title: module.title,
          description: module.description,
          videoUrl: module.videoUrl,
          order: i,
          lessons: module.lessons,
        );
      }
    }
  }
}
