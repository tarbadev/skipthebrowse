import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_token.dart';
import 'user_dto.dart';

part 'auth_response_dto.g.dart';

@JsonSerializable()
class AuthResponseDto {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final UserDto user;

  AuthResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);

  AuthSession toEntity() {
    return AuthSession(
      user: user.toEntity(),
      token: AuthToken(accessToken: accessToken, tokenType: tokenType),
    );
  }
}
