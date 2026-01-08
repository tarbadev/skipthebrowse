// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_interaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddInteractionRequest _$AddInteractionRequestFromJson(
  Map<String, dynamic> json,
) => AddInteractionRequest(
  choiceId: json['choice_id'] as String,
  customInput: json['custom_input'] as String?,
);

Map<String, dynamic> _$AddInteractionRequestToJson(
  AddInteractionRequest instance,
) => <String, dynamic>{
  'choice_id': instance.choiceId,
  'custom_input': instance.customInput,
};
