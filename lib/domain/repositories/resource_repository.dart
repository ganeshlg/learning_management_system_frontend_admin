import 'package:learning_management_system_trainer/domain/entities/resource.dart';

abstract class ResourceRepository {
  Future<List<Resource>> getResources();
  Future<Resource> createResource(Resource resource);
  Future<void> deleteResource(String id);
}
