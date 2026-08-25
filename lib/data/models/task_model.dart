class TaskModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assigneeId;
  final DateTime dueDate;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assigneeId,
    required this.dueDate,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      assigneeId: json['assignee_id'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  TaskModel copyWith({String? title, String? description, String? status,
      String? priority, String? assigneeId, bool clearAssignee = false, DateTime? dueDate}) =>
      TaskModel(id: id, projectId: projectId, title: title ?? this.title,
          description: description ?? this.description, status: status ?? this.status,
          priority: priority ?? this.priority,
          assigneeId: clearAssignee ? null : assigneeId ?? this.assigneeId,
          dueDate: dueDate ?? this.dueDate, createdAt: createdAt);
}
