import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction_prompt.dart';
import 'structured_choice_response.dart';

part 'interaction_prompt_response.g.dart';

@JsonSerializable()
class InteractionPromptResponse {
  @JsonKey(name: 'prompt_prefix')
  final String promptPrefix;
  final List<StructuredChoiceResponse> choices;
  @JsonKey(name: 'allow_skip')
  final bool allowSkip;

  factory InteractionPromptResponse.fromJson(Map<String, dynamic> json) =>
      _$InteractionPromptResponseFromJson(json);

  InteractionPromptResponse({
    required this.promptPrefix,
    required this.choices,
    required this.allowSkip,
  });

  Map<String, dynamic> toJson() => _$InteractionPromptResponseToJson(this);

  InteractionPrompt toEntity() => InteractionPrompt(
    promptPrefix: promptPrefix,
    choices: choices.map((c) => c.toEntity()).toList(),
    allowSkip: allowSkip,
  );
}
