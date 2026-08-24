class OrganizationModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const OrganizationModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}