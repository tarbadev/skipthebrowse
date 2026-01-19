import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction_prompt.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/domain/entities/structured_choice.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';
import 'package:skipthebrowse/features/search/domain/state/search_session_notifier.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository mockRepository;
  late SearchSessionNotifier notifier;

  setUp(() {
    mockRepository = MockSearchRepository();
    notifier = SearchSessionNotifier(mockRepository);
  });

  group('SearchSessionNotifier - Null Safety', () {
    test(
      'addInteraction should return early if session has no interactions',
      () async {
        // Setup: Create a session with empty interactions list
        final session = SearchSession(
          id: 'session-123',
          initialMessage: 'test message',
          interactions: [], // Empty list
          recommendations: [],
          createdAt: DateTime.now(),
        );

        notifier.setSession(session);

        // Attempt to add interaction
        await notifier.addInteraction(
          'session-123',
          'choice-1',
          customInput: 'test',
        );

        // Should not call repository (returned early)
        verifyNever(
          () => mockRepository.addInteraction(
            any(),
            any(),
            customInput: any(named: 'customInput'),
          ),
        );
      },
    );

    test(
      'addInteraction should return early if last interaction has no choices',
      () async {
        // Setup: Create interaction with empty choices list
        final interaction = Interaction(
          id: 'interaction-1',
          userInput: null,
          assistantPrompt: InteractionPrompt(
            promptPrefix: 'Choose something',
            choices: [], // Empty choices list
            allowSkip: false,
          ),
          timestamp: DateTime.now(),
        );

        final session = SearchSession(
          id: 'session-123',
          initialMessage: 'test message',
          interactions: [interaction],
          recommendations: [],
          createdAt: DateTime.now(),
        );

        notifier.setSession(session);

        // Attempt to add interaction
        await notifier.addInteraction(
          'session-123',
          'choice-1',
          customInput: 'test',
        );

        // Should not call repository (returned early)
        verifyNever(
          () => mockRepository.addInteraction(
            any(),
            any(),
            customInput: any(named: 'customInput'),
          ),
        );
      },
    );

    test(
      'addInteraction should use first choice as fallback if selected choice not found',
      () async {
        // Setup: Create interaction with choices
        final choice1 = StructuredChoice(
          id: 'choice-1',
          displayText: 'First Choice',
          acceptsTextInput: false,
          inputPlaceholder: null,
        );

        final choice2 = StructuredChoice(
          id: 'choice-2',
          displayText: 'Second Choice',
          acceptsTextInput: false,
          inputPlaceholder: null,
        );

        final interaction = Interaction(
          id: 'interaction-1',
          userInput: null,
          assistantPrompt: InteractionPrompt(
            promptPrefix: 'Choose something',
            choices: [choice1, choice2],
            allowSkip: false,
          ),
          timestamp: DateTime.now(),
        );

        final session = SearchSession(
          id: 'session-123',
          initialMessage: 'test message',
          interactions: [interaction],
          recommendations: [],
          createdAt: DateTime.now(),
        );

        notifier.setSession(session);

        // Mock repository response
        final updatedSession = SearchSession(
          id: 'session-123',
          initialMessage: 'test message',
          interactions: [
            Interaction(
              id: 'interaction-1',
              userInput: 'First Choice', // Should use first choice as fallback
              assistantPrompt: interaction.assistantPrompt,
              timestamp: interaction.timestamp,
            ),
          ],
          recommendations: [],
          createdAt: session.createdAt,
        );

        when(
          () => mockRepository.addInteraction(
            'session-123',
            'nonexistent-choice-id',
            customInput: null,
          ),
        ).thenAnswer((_) async => updatedSession);

        // Try to add interaction with non-existent choice ID
        await notifier.addInteraction('session-123', 'nonexistent-choice-id');

        // Should still call repository (didn't crash)
        verify(
          () => mockRepository.addInteraction(
            'session-123',
            'nonexistent-choice-id',
            customInput: null,
          ),
        ).called(1);
      },
    );

    test('addInteraction should handle valid choice correctly', () async {
      // Setup: Create interaction with choices
      final choice1 = StructuredChoice(
        id: 'choice-1',
        displayText: 'Action Movies',
        acceptsTextInput: false,
        inputPlaceholder: null,
      );

      final choice2 = StructuredChoice(
        id: 'choice-2',
        displayText: 'Comedy Movies',
        acceptsTextInput: false,
        inputPlaceholder: null,
      );

      final interaction = Interaction(
        id: 'interaction-1',
        userInput: null,
        assistantPrompt: InteractionPrompt(
          promptPrefix: 'What genre?',
          choices: [choice1, choice2],
          allowSkip: false,
        ),
        timestamp: DateTime.now(),
      );

      final session = SearchSession(
        id: 'session-123',
        initialMessage: 'test message',
        interactions: [interaction],
        recommendations: [],
        createdAt: DateTime.now(),
      );

      notifier.setSession(session);

      // Mock repository response
      final updatedSession = SearchSession(
        id: 'session-123',
        initialMessage: 'test message',
        interactions: [
          Interaction(
            id: 'interaction-1',
            userInput: 'Comedy Movies',
            assistantPrompt: interaction.assistantPrompt,
            timestamp: interaction.timestamp,
          ),
        ],
        recommendations: [],
        createdAt: session.createdAt,
      );

      when(
        () => mockRepository.addInteraction(
          'session-123',
          'choice-2',
          customInput: null,
        ),
      ).thenAnswer((_) async => updatedSession);

      // Add interaction with valid choice
      await notifier.addInteraction('session-123', 'choice-2');

      // Verify repository was called
      verify(
        () => mockRepository.addInteraction(
          'session-123',
          'choice-2',
          customInput: null,
        ),
      ).called(1);
    });

    test(
      'addInteraction should handle choice with custom input correctly',
      () async {
        // Setup: Create interaction with choices that accept text input
        final choice = StructuredChoice(
          id: 'choice-other',
          displayText: 'Other',
          acceptsTextInput: true,
          inputPlaceholder: 'Tell us more...',
        );

        final interaction = Interaction(
          id: 'interaction-1',
          userInput: null,
          assistantPrompt: InteractionPrompt(
            promptPrefix: 'What genre?',
            choices: [choice],
            allowSkip: false,
          ),
          timestamp: DateTime.now(),
        );

        final session = SearchSession(
          id: 'session-123',
          initialMessage: 'test message',
          interactions: [interaction],
          recommendations: [],
          createdAt: DateTime.now(),
        );

        notifier.setSession(session);

        // Mock repository response
        final updatedSession = SearchSession(
          id: 'session-123',
          initialMessage: 'test message',
          interactions: [
            Interaction(
              id: 'interaction-1',
              userInput: 'Other: Sci-fi thriller',
              assistantPrompt: interaction.assistantPrompt,
              timestamp: interaction.timestamp,
            ),
          ],
          recommendations: [],
          createdAt: session.createdAt,
        );

        when(
          () => mockRepository.addInteraction(
            'session-123',
            'choice-other',
            customInput: 'Sci-fi thriller',
          ),
        ).thenAnswer((_) async => updatedSession);

        // Add interaction with custom input
        await notifier.addInteraction(
          'session-123',
          'choice-other',
          customInput: 'Sci-fi thriller',
        );

        // Verify repository was called with custom input
        verify(
          () => mockRepository.addInteraction(
            'session-123',
            'choice-other',
            customInput: 'Sci-fi thriller',
          ),
        ).called(1);
      },
    );
  });
}
