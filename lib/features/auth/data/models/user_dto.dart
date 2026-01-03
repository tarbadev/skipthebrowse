import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String username;
  final String? email;
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;

  UserDto({
    required this.id,
    required this.username,
    this.email,
    required this.isAnonymous,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      isAnonymous: isAnonymous,
    );
  }
}
