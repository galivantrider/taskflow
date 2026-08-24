class OrgMemberModel {
  final String orgId;
  final String userId;
  final String role;

  const OrgMemberModel({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  factory OrgMemberModel.fromJson(Map<String, dynamic> json) {
    return OrgMemberModel(
      orgId: json['org_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
    );
  }

  bool get isAdmin => role == 'org_admin';
}