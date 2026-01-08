import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/search/data/models/interaction_prompt_response.dart';
import 'package:skipthebrowse/features/search/data/models/structured_choice_response.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction_prompt.dart';

void main() {
  group('InteractionPromptResponse', () {
    test('fromJson creates instance from JSON', () {
      final json = {
        'prompt_prefix': "I'm more into...",
        'choices': [
          {
            'id': 'action',
            'display_text': 'Action',
            'accepts_text_input': false,
            'input_placeholder': null,
          },
          {
            'id': 'comedy',
            'display_text': 'Comedy',
            'accepts_text_input': false,
            'input_placeholder': null,
          },
          {
            'id': 'other',
            'display_text': 'Other',
            'accepts_text_input': true,
            'input_placeholder': 'Tell us more...',
          },
        ],
        'allow_skip': false,
      };

      final response = InteractionPromptResponse.fromJson(json);

      expect(response.promptPrefix, "I'm more into...");
      expect(response.choices.length, 3);
      expect(response.choices[0].id, 'action');
      expect(response.choices[1].id, 'comedy');
      expect(response.choices[2].acceptsTextInput, true);
      expect(response.allowSkip, false);
    });

    test('toJson converts to JSON', () {
      final response = InteractionPromptResponse(
        promptPrefix: "I'm looking for...",
        choices: [
          StructuredChoiceResponse(
            id: 'action',
            displayText: 'Action',
            acceptsTextInput: false,
          ),
          StructuredChoiceResponse(
            id: 'drama',
            displayText: 'Drama',
            acceptsTextInput: false,
          ),
        ],
        allowSkip: false,
      );

      final json = response.toJson();

      expect(json['prompt_prefix'], "I'm looking for...");
      expect((json['choices'] as List).length, 2);
      expect(json['allow_skip'], false);
    });

    test('toEntity converts to domain entity', () {
      final response = InteractionPromptResponse(
        promptPrefix: 'What genre?',
        choices: [
          StructuredChoiceResponse(
            id: 'thriller',
            displayText: 'Thriller',
            acceptsTextInput: false,
          ),
        ],
        allowSkip: true,
      );

      final entity = response.toEntity();

      expect(entity, isA<InteractionPrompt>());
      expect(entity.promptPrefix, 'What genre?');
      expect(entity.choices.length, 1);
      expect(entity.allowSkip, true);
    });
  });
}
