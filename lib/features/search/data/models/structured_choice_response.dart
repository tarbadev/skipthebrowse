import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/search/domain/entities/structured_choice.dart';

part 'structured_choice_response.g.dart';

@JsonSerializable()
class StructuredChoiceResponse {
  final String id;
  @JsonKey(name: 'display_text')
  final String displayText;
  @JsonKey(name: 'accepts_text_input')
  final bool acceptsTextInput;
  @JsonKey(name: 'input_placeholder')
  final String? inputPlaceholder;

  factory StructuredChoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$StructuredChoiceResponseFromJson(json);

  StructuredChoiceResponse({
    required this.id,
    required this.displayText,
    required this.acceptsTextInput,
    this.inputPlaceholder,
  });

  Map<String, dynamic> toJson() => _$StructuredChoiceResponseToJson(this);

  StructuredChoice toEntity() => StructuredChoice(
    id: id,
    displayText: displayText,
    acceptsTextInput: acceptsTextInput,
    inputPlaceholder: inputPlaceholder,
  );
}
