import '../../data/models/auth_response_model.dart';
import '../../data/models/auth_credentials_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> refreshToken();

  Future<void> logout();

  Future<bool> hasValidSession();
  Future<AuthCredentialsModel?> credentialsForEmail(String email);
}
