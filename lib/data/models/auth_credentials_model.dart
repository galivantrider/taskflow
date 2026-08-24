class AuthCredentialsModel {
  final String email;
  final String password;
  final String orgId;
  final String role;

  const AuthCredentialsModel({
    required this.email,
    required this.password,
    required this.orgId,
    required this.role,
  });

  factory AuthCredentialsModel.fromJson(Map<String, dynamic> json) {
    return AuthCredentialsModel(
      email: json['email'] as String,
      password: json['password'] as String,
      orgId: json['org_id'] as String,
      role: json['role'] as String,
    );
  }
}