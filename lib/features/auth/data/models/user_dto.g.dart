// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String?,
  isAnonymous: json['is_anonymous'] as bool,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'is_anonymous': instance.isAnonymous,
};
