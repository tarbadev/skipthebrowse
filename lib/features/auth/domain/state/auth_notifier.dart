import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/auth_session.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthNotifier extends StateNotifier<AsyncValue<AuthSession?>> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AsyncValue.data(null)) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final session = await repository.getSession();
      state = AsyncValue.data(session);
    } catch (err, stack) {
      state = AsyncError<AuthSession?>(err, stack);
    }
  }

  Future<void> createAnonymousUser(String username) async {
    state = const AsyncValue.loading();
    try {
      final session = await repository.createAnonymousUser(username);
      state = AsyncValue.data(session);
    } catch (err, stack) {
      state = AsyncError<AuthSession?>(err, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await repository.clearSession();
      state = const AsyncValue.data(null);
    } catch (err, stack) {
      state = AsyncError<AuthSession?>(err, stack);
    }
  }

  User? get currentUser => state.value?.user;
  String? get token => state.value?.token.accessToken;
  String? get authorizationHeader => state.value?.token.authorizationHeader;
  bool get isAuthenticated => state.value != null;
}
