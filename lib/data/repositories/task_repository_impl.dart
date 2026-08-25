import '../../domain/repositories/task_repository.dart';
import '../datasources/mock_data_source.dart';
import '../models/org_member_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._source); final MockDataSource _source;
  List<TaskModel>? _tasks;
  Future<List<TaskModel>> _all() async => _tasks ??= (await _source.getList('tasks')).map(TaskModel.fromJson).toList();
  @override Future<List<TaskModel>> getTasks(String projectId) async => (await _all()).where((item) => item.projectId == projectId).toList();
  @override Future<TaskModel> createTask({required String projectId, required String title, required String description, required String priority, DateTime? dueDate}) async {
    final task = TaskModel(id: 'task_${DateTime.now().microsecondsSinceEpoch}', projectId: projectId, title: title, description: description,
      status: 'todo', priority: priority, assigneeId: null, dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)), createdAt: DateTime.now());
    (await _all()).add(task); return task;
  }
  @override Future<TaskModel> updateTask(TaskModel task) async { final tasks = await _all(); final index = tasks.indexWhere((item) => item.id == task.id); if (index < 0) throw Exception('Task not found'); tasks[index] = task; return task; }
  @override Future<void> deleteTask(String id) async { final tasks = await _all(); if (!tasks.any((item) => item.id == id)) throw Exception('Task not found'); tasks.removeWhere((item) => item.id == id); }
  @override Future<void> assignTask({required String taskId, required String? userId, required String orgId}) async {
    if (userId != null) { final members = (await _source.getList('org_members')).map(OrgMemberModel.fromJson); if (!members.any((m) => m.orgId == orgId && m.userId == userId)) throw Exception('Assignee does not belong to this organization'); }
    final tasks = await _all(); final index = tasks.indexWhere((item) => item.id == taskId); if(index < 0) throw Exception('Task not found'); tasks[index] = tasks[index].copyWith(assigneeId: userId, clearAssignee: userId == null);
  }
  @override Future<List<UserModel>> getOrgMembers(String orgId) async {
    final ids = (await _source.getList('org_members')).map(OrgMemberModel.fromJson).where((m) => m.orgId == orgId).map((m) => m.userId).toSet();
    return (await _source.getList('users')).map(UserModel.fromJson).where((u) => ids.contains(u.id)).toList();
  }
}
