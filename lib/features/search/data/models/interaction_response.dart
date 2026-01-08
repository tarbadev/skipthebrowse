import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction.dart';
import 'interaction_prompt_response.dart';

part 'interaction_response.g.dart';

@JsonSerializable()
class InteractionResponse {
  final String id;
  @JsonKey(name: 'user_input')
  final String? userInput;
  @JsonKey(name: 'assistant_prompt')
  final InteractionPromptResponse assistantPrompt;
  final DateTime timestamp;

  factory InteractionResponse.fromJson(Map<String, dynamic> json) =>
      _$InteractionResponseFromJson(json);

  InteractionResponse({
    required this.id,
    required this.userInput,
    required this.assistantPrompt,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => _$InteractionResponseToJson(this);

  Interaction toEntity() => Interaction(
    id: id,
    userInput: userInput,
    assistantPrompt: assistantPrompt.toEntity(),
    timestamp: timestamp,
  );
}
