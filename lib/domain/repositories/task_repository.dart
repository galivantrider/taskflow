import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks(String projectId);
  Future<TaskModel> createTask({required String projectId, required String title, required String description, required String priority, DateTime? dueDate});
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<TaskModel> assignTask({required String taskId, required String? userId, required String orgId});
  Future<List<UserModel>> getOrgMembers(String orgId);
}
