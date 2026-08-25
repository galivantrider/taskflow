import '../../data/models/project_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> getProjects(String orgId);
  Future<ProjectModel> createProject({required String orgId, required String name, required String description});
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> deleteProject({required String projectId, required bool isAdmin});
}
