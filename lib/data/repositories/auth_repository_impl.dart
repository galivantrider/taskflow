import '../datasources/mock_data_source.dart';
import '../models/auth_credentials_model.dart';
import '../models/auth_response_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final auth = await dataSource.getObject('auth_mock');

    final credentials = (auth['test_credentials'] as List)
        .map(
          (item) => AuthCredentialsModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    final user = credentials.where(
      (item) => item.email == email && item.password == password,
    );

    if (user.isEmpty) {
      throw Exception('Invalid email or password');
    }

    return AuthResponseModel.fromJson(
      Map<String, dynamic>.from(
        auth['mock_login_response'] as Map,
      ),
    );
  }

  @override
  Future<AuthResponseModel> refreshToken() async {
    final auth = await dataSource.getObject('auth_mock');

    return AuthResponseModel.fromJson(
      Map<String, dynamic>.from(
        auth['mock_login_response'] as Map,
      ),
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> hasValidSession() async {
    return true;
  }

  @override
  Future<AuthCredentialsModel?> credentialsForEmail(String email) async {
    final auth = await dataSource.getObject('auth_mock');
    final credentials = (auth['test_credentials'] as List)
        .map((item) => AuthCredentialsModel.fromJson(Map<String, dynamic>.from(item as Map)));
    for (final credential in credentials) {
      if (credential.email == email) return credential;
    }
    return null;
  }
}
