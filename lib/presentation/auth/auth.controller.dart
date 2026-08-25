import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final String? email;
  final String? orgId;
  final String? role;

  const AuthState({
    required this.status,
    this.errorMessage,
    this.email,
    this.orgId,
    this.role,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        errorMessage = null,
        email = null,
        orgId = null,
        role = null;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? email,
    String? orgId,
    String? role,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      email: email ?? this.email,
      orgId: orgId ?? this.orgId,
      role: role ?? this.role,
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
      final credential = await repository.credentialsForEmail(email);

      final expiry = DateTime.now().add(
        Duration(
          seconds: response.accessTokenExpiresInSeconds,
        ),
      );

      await storage.saveSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        accessTokenExpiry: expiry,
        email: email,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        email: email,
        orgId: credential?.orgId,
        role: credential?.role,
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

  Future<void> restore() async {
    final storage = ref.read(secureStorageProvider);
    final expiry = await storage.getAccessTokenExpiry();
    final email = await storage.getSessionEmail();
    if (expiry == null || email == null) { state = state.copyWith(status: AuthStatus.unauthenticated); return; }
    if (expiry.isBefore(DateTime.now())) {
      final response = await ref.read(authRepositoryProvider).refreshToken();
      await storage.saveSession(accessToken: response.accessToken, refreshToken: response.refreshToken,
          accessTokenExpiry: DateTime.now().add(Duration(seconds: response.accessTokenExpiresInSeconds)), email: email);
    }
    final credential = await ref.read(authRepositoryProvider).credentialsForEmail(email);
    state = state.copyWith(status: AuthStatus.authenticated, email: email, orgId: credential?.orgId, role: credential?.role);
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);

    await storage.clearSession();

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
    );
  }
}
