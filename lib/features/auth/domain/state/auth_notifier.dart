import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/state/base_async_notifier.dart';
import '../entities/auth_session.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthNotifier extends BaseAsyncNotifier<AuthSession?> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AsyncValue.data(null)) {
    _init();
  }

  Future<void> _init() => execute(() => repository.getSession());

  Future<void> createAnonymousUser(String username) =>
      execute(() => repository.createAnonymousUser(username));

  Future<void> logout() => executeWithTransform(
    operation: () => repository.clearSession(),
    transform: (_) => null,
  );

  Future<void> registerUser({
    required String email,
    required String password,
    required String username,
  }) => execute(
    () => repository.registerUser(
      email: email,
      password: password,
      username: username,
    ),
  );

  Future<void> loginUser({required String email, required String password}) =>
      execute(() => repository.loginUser(email: email, password: password));

  Future<void> mergeAnonymousAccount({
    required String email,
    required String password,
  }) => execute(
    () => repository.mergeAnonymousAccount(email: email, password: password),
  );

  User? get currentUser => state.value?.user;
  String? get token => state.value?.token.accessToken;
  String? get authorizationHeader => state.value?.token.authorizationHeader;
  bool get isAuthenticated => state.value != null;
}
