class ProjectModel {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final int taskCount;
  final String status;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.status,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      taskCount: json['task_count'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ProjectModel copyWith({String? name, String? description, int? taskCount}) =>
      ProjectModel(id: id, orgId: orgId, name: name ?? this.name,
          description: description ?? this.description, taskCount: taskCount ?? this.taskCount,
          status: status, createdAt: createdAt);
}
