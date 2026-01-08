import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/search/domain/entities/structured_choice.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction_prompt.dart';
import 'package:skipthebrowse/features/search/presentation/widgets/interaction_prompt_widget.dart';

void main() {
  group('InteractionPromptWidget', () {
    testWidgets('displays prompt prefix and choice buttons', (
      WidgetTester tester,
    ) async {
      final prompt = InteractionPrompt(
        promptPrefix: "I'm more into...",
        choices: const [
          StructuredChoice(
            id: 'action',
            displayText: 'Action',
            acceptsTextInput: false,
          ),
          StructuredChoice(
            id: 'comedy',
            displayText: 'Comedy',
            acceptsTextInput: false,
          ),
        ],
        allowSkip: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractionPromptWidget(
              prompt: prompt,
              onSubmit: (choiceId, customInput) {},
            ),
          ),
        ),
      );

      expect(find.text("I'm more into..."), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Comedy'), findsOneWidget);
      expect(
        find.text('Continue'),
        findsNothing,
      ); // No button until choice selected
    });

    testWidgets('shows continue button after selecting a choice', (
      WidgetTester tester,
    ) async {
      final prompt = InteractionPrompt(
        promptPrefix: "Select a genre",
        choices: const [
          StructuredChoice(
            id: 'thriller',
            displayText: 'Thriller',
            acceptsTextInput: false,
          ),
        ],
        allowSkip: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractionPromptWidget(
              prompt: prompt,
              onSubmit: (choiceId, customInput) {},
            ),
          ),
        ),
      );

      // Tap the choice
      await tester.tap(find.text('Thriller'));
      await tester.pumpAndSettle();

      // Continue button should appear
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows text input when choice accepts text input', (
      WidgetTester tester,
    ) async {
      final prompt = InteractionPrompt(
        promptPrefix: "I'm looking for...",
        choices: const [
          StructuredChoice(
            id: 'other',
            displayText: 'Other',
            acceptsTextInput: true,
            inputPlaceholder: 'Tell us more...',
          ),
        ],
        allowSkip: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractionPromptWidget(
              prompt: prompt,
              onSubmit: (choiceId, customInput) {},
            ),
          ),
        ),
      );

      // Tap the choice that accepts text input
      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();

      // Text field should appear
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Tell us more...'), findsOneWidget);
    });

    testWidgets('calls onSubmit with choice and optional input', (
      WidgetTester tester,
    ) async {
      String? submittedChoiceId;
      String? submittedInput;

      final prompt = InteractionPrompt(
        promptPrefix: "Choose one",
        choices: const [
          StructuredChoice(
            id: 'option1',
            displayText: 'Option 1',
            acceptsTextInput: true,
          ),
        ],
        allowSkip: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractionPromptWidget(
              prompt: prompt,
              onSubmit: (choiceId, customInput) {
                submittedChoiceId = choiceId;
                submittedInput = customInput;
              },
            ),
          ),
        ),
      );

      // Select choice
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      // Enter text (optional)
      await tester.enterText(find.byType(TextField), 'Custom input');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submittedChoiceId, 'option1');
      expect(submittedInput, 'Custom input');
    });

    testWidgets('can submit without custom input when optional', (
      WidgetTester tester,
    ) async {
      String? submittedChoiceId;
      String? submittedInput;

      final prompt = InteractionPrompt(
        promptPrefix: "Choose one",
        choices: const [
          StructuredChoice(
            id: 'option1',
            displayText: 'Option 1',
            acceptsTextInput: true,
          ),
        ],
        allowSkip: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractionPromptWidget(
              prompt: prompt,
              onSubmit: (choiceId, customInput) {
                submittedChoiceId = choiceId;
                submittedInput = customInput;
              },
            ),
          ),
        ),
      );

      // Select choice
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      // Submit without entering text
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(submittedChoiceId, 'option1');
      expect(submittedInput, null); // No custom input
    });
  });
}
