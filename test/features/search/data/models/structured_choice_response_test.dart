import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/search/data/models/structured_choice_response.dart';
import 'package:skipthebrowse/features/search/domain/entities/structured_choice.dart';

void main() {
  group('StructuredChoiceResponse', () {
    test('fromJson creates instance from JSON', () {
      final json = {
        'id': 'action',
        'display_text': 'Action',
        'accepts_text_input': false,
        'input_placeholder': null,
      };

      final response = StructuredChoiceResponse.fromJson(json);

      expect(response.id, 'action');
      expect(response.displayText, 'Action');
      expect(response.acceptsTextInput, false);
      expect(response.inputPlaceholder, null);
    });

    test('fromJson creates instance with input placeholder', () {
      final json = {
        'id': 'other',
        'display_text': 'Other',
        'accepts_text_input': true,
        'input_placeholder': 'Tell us more...',
      };

      final response = StructuredChoiceResponse.fromJson(json);

      expect(response.id, 'other');
      expect(response.displayText, 'Other');
      expect(response.acceptsTextInput, true);
      expect(response.inputPlaceholder, 'Tell us more...');
    });

    test('toJson converts to JSON', () {
      final response = StructuredChoiceResponse(
        id: 'comedy',
        displayText: 'Comedy',
        acceptsTextInput: false,
      );

      final json = response.toJson();

      expect(json['id'], 'comedy');
      expect(json['display_text'], 'Comedy');
      expect(json['accepts_text_input'], false);
    });

    test('toEntity converts to domain entity', () {
      final response = StructuredChoiceResponse(
        id: 'action',
        displayText: 'Action',
        acceptsTextInput: true,
        inputPlaceholder: 'Please specify',
      );

      final entity = response.toEntity();

      expect(entity, isA<StructuredChoice>());
      expect(entity.id, 'action');
      expect(entity.displayText, 'Action');
      expect(entity.acceptsTextInput, true);
      expect(entity.inputPlaceholder, 'Please specify');
    });
  });
}
