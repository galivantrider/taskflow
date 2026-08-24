import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/presentation/auth/auth.provider.dart';
import 'auth.provider.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);

      final response = await repository.login(
        email: email,
        password: password,
      );

      final expiry = DateTime.now().add(
        Duration(
          seconds: response.accessTokenExpiresInSeconds,
        ),
      );

      await storage.saveSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        accessTokenExpiry: expiry,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);

    await storage.clearSession();

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
    );
  }
}