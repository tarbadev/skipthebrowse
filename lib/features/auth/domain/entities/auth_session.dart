import 'package:equatable/equatable.dart';
import 'user.dart';
import 'auth_token.dart';

class AuthSession extends Equatable {
  final User user;
  final AuthToken token;

  const AuthSession({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}
