import 'package:learning_management_system_trainer/data/mock/mock_data.dart';
import 'package:learning_management_system_trainer/domain/entities/resource.dart';
import 'package:learning_management_system_trainer/domain/repositories/resource_repository.dart';

class MockResourceRepository implements ResourceRepository {
  @override
  Future<List<Resource>> getResources() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.resources;
  }

  @override
  Future<Resource> createResource(Resource resource) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newResource = Resource(
      id: 'res-${MockData.resources.length + 1}',
      name: resource.name,
      type: resource.type,
      url: resource.url,
      courseId: resource.courseId,
      moduleId: resource.moduleId,
      lessonId: resource.lessonId,
    );
    MockData.resources.add(newResource);
    return newResource;
  }

  @override
  Future<void> deleteResource(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.resources.removeWhere((r) => r.id == id);
  }
}
