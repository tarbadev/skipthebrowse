import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String tokenType;

  const AuthToken({required this.accessToken, required this.tokenType});

  @override
  List<Object?> get props => [accessToken, tokenType];

  String get authorizationHeader => '$tokenType $accessToken';
}
