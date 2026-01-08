import 'package:json_annotation/json_annotation.dart';

part 'add_interaction_request.g.dart';

@JsonSerializable()
class AddInteractionRequest {
  @JsonKey(name: 'choice_id')
  final String choiceId;
  @JsonKey(name: 'custom_input')
  final String? customInput;

  AddInteractionRequest({required this.choiceId, this.customInput});

  factory AddInteractionRequest.fromJson(Map<String, dynamic> json) =>
      _$AddInteractionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddInteractionRequestToJson(this);
}
