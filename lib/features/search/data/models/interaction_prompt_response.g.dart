// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_prompt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InteractionPromptResponse _$InteractionPromptResponseFromJson(
  Map<String, dynamic> json,
) => InteractionPromptResponse(
  promptPrefix: json['prompt_prefix'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => StructuredChoiceResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  allowSkip: json['allow_skip'] as bool,
);

Map<String, dynamic> _$InteractionPromptResponseToJson(
  InteractionPromptResponse instance,
) => <String, dynamic>{
  'prompt_prefix': instance.promptPrefix,
  'choices': instance.choices,
  'allow_skip': instance.allowSkip,
};
