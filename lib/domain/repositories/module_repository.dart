import 'package:learning_management_system_trainer/domain/entities/module.dart';

abstract class ModuleRepository {
  Future<List<Module>> getModulesByCourseId(String courseId);
  Future<Module> createModule(Module module);
  Future<Module> updateModule(Module module);
  Future<void> deleteModule(String id);
  Future<void> reorderModules(List<String> moduleIds);
}
