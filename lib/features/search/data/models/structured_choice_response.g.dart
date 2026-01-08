// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'structured_choice_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StructuredChoiceResponse _$StructuredChoiceResponseFromJson(
  Map<String, dynamic> json,
) => StructuredChoiceResponse(
  id: json['id'] as String,
  displayText: json['display_text'] as String,
  acceptsTextInput: json['accepts_text_input'] as bool,
  inputPlaceholder: json['input_placeholder'] as String?,
);

Map<String, dynamic> _$StructuredChoiceResponseToJson(
  StructuredChoiceResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'display_text': instance.displayText,
  'accepts_text_input': instance.acceptsTextInput,
  'input_placeholder': instance.inputPlaceholder,
};
