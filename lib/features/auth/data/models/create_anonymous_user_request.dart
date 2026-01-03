import 'package:json_annotation/json_annotation.dart';

part 'create_anonymous_user_request.g.dart';

@JsonSerializable()
class CreateAnonymousUserRequest {
  final String username;

  CreateAnonymousUserRequest({required this.username});

  factory CreateAnonymousUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAnonymousUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAnonymousUserRequestToJson(this);
}
