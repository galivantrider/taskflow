import '../../domain/repositories/project_repository.dart';
import '../datasources/mock_data_source.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._source);
  final MockDataSource _source;
  List<ProjectModel>? _projects;

  Future<List<ProjectModel>> _all() async => _projects ??= (await _source.getList('projects'))
      .map((json) => ProjectModel.fromJson(json)).toList();
  @override Future<List<ProjectModel>> getProjects(String orgId) async =>
      (await _all()).where((item) => item.orgId == orgId).toList();
  @override Future<ProjectModel> createProject({required String orgId, required String name, required String description}) async {
    final project = ProjectModel(id: 'proj_${DateTime.now().microsecondsSinceEpoch}', orgId: orgId, name: name,
        description: description, taskCount: 0, status: 'active', createdAt: DateTime.now());
    (await _all()).add(project); return project;
  }
  @override Future<ProjectModel> updateProject(ProjectModel project) async {
    final projects = await _all(); final index = projects.indexWhere((item) => item.id == project.id);
    if (index < 0) throw Exception('Project not found'); projects[index] = project; return project;
  }
  @override Future<void> deleteProject({required String projectId, required bool isAdmin}) async {
    if (!isAdmin) throw Exception('Only organization admins can delete projects');
    final projects = await _all();
    if (!projects.any((item) => item.id == projectId)) throw Exception('Project not found');
    projects.removeWhere((item) => item.id == projectId);
  }
}
