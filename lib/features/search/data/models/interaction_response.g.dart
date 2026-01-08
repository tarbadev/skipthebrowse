// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InteractionResponse _$InteractionResponseFromJson(Map<String, dynamic> json) =>
    InteractionResponse(
      id: json['id'] as String,
      userInput: json['user_input'] as String?,
      assistantPrompt: InteractionPromptResponse.fromJson(
        json['assistant_prompt'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$InteractionResponseToJson(
  InteractionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_input': instance.userInput,
  'assistant_prompt': instance.assistantPrompt,
  'timestamp': instance.timestamp.toIso8601String(),
};
