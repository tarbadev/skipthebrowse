import 'package:json_annotation/json_annotation.dart';

part 'create_conversation_request.g.dart';

@JsonSerializable()
class CreateConversationRequest {
  final String message;
  final String region;

  CreateConversationRequest({required this.message, required this.region});

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}
