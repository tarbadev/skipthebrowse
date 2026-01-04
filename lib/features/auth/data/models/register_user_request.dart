import 'package:json_annotation/json_annotation.dart';

part 'register_user_request.g.dart';

@JsonSerializable()
class RegisterUserRequest {
  final String email;
  final String password;
  final String username;

  const RegisterUserRequest({
    required this.email,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() => _$RegisterUserRequestToJson(this);
}
