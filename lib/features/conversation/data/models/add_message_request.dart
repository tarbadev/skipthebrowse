import 'package:json_annotation/json_annotation.dart';

part 'add_message_request.g.dart';

@JsonSerializable()
class AddMessageRequest {
  final String message;

  AddMessageRequest({required this.message});

  factory AddMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$AddMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddMessageRequestToJson(this);
}
