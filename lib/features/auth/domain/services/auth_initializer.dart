import 'dart:math';
import '../repositories/auth_repository.dart';

class AuthInitializer {
  final AuthRepository authRepository;

  AuthInitializer(this.authRepository);

  /// Initialize authentication on app startup.
  /// Creates an anonymous user if no session exists.
  Future<void> initialize() async {
    final existingSession = await authRepository.getSession();

    // If user is already authenticated, do nothing
    if (existingSession != null) {
      return;
    }

    // Create anonymous user with movie-themed username
    final username = _generateMovieUsername();
    await authRepository.createAnonymousUser(username);
  }

  /// Generate a random movie-themed username
  String _generateMovieUsername() {
    final movieCharacters = [
      'han-solo',
      'luke-skywalker',
      'leia-organa',
      'darth-vader',
      'yoda',
      'obiwan',
      'gandalf',
      'frodo',
      'aragorn',
      'legolas',
      'neo',
      'morpheus',
      'trinity',
      'indiana-jones',
      'marty-mcfly',
      'doc-brown',
      'tony-stark',
      'peter-parker',
      'bruce-wayne',
      'clark-kent',
    ];

    final random = Random();
    final character = movieCharacters[random.nextInt(movieCharacters.length)];
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');

    return '$character-$randomSuffix';
  }
}
