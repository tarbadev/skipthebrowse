import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction_prompt.dart';
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

  tearDown(() {
    notifier.dispose();
  });

  group('SearchSessionNotifier', () {
    test('initial state is AsyncData(null)', () {
      expect(notifier.state, isA<AsyncData<SearchSession?>>());
      expect(notifier.state.value, isNull);
    });

    test(
      'createSession updates state to loading then data on success',
      () async {
        final mockSession = SearchSession(
          id: 'session-1',
          interactions: [
            Interaction(
              id: 'int-1',
              userInput: null,
              assistantPrompt: const InteractionPrompt(
                promptPrefix: "What genre?",
                choices: [
                  StructuredChoice(
                    id: 'action',
                    displayText: 'Action',
                    acceptsTextInput: false,
                  ),
                ],
                allowSkip: false,
              ),
              timestamp: DateTime.now(),
            ),
          ],
          recommendations: [],
          createdAt: DateTime.now(),
        );

        when(
          () => mockRepository.createSearchSession('thriller'),
        ).thenAnswer((_) async => mockSession);

        final future = notifier.createSession('thriller');

        // Should be loading
        expect(notifier.state.isLoading, true);

        await future;

        // Should have data
        expect(notifier.state.value, mockSession);
        verify(() => mockRepository.createSearchSession('thriller')).called(1);
      },
    );

    test('createSession updates state to error on failure', () async {
      when(
        () => mockRepository.createSearchSession('test'),
      ).thenThrow(Exception('API Error'));

      await notifier.createSession('test');

      expect(notifier.state, isA<AsyncError<SearchSession?>>());
      expect(notifier.state.error.toString(), contains('API Error'));
    });

    test('addInteraction updates state with optimistic update', () async {
      final session = SearchSession(
        id: 'session-1',
        interactions: [
          Interaction(
            id: 'int-1',
            userInput: null,
            assistantPrompt: const InteractionPrompt(
              promptPrefix: "What genre?",
              choices: [
                StructuredChoice(
                  id: 'action',
                  displayText: 'Action',
                  acceptsTextInput: false,
                ),
              ],
              allowSkip: false,
            ),
            timestamp: DateTime.now(),
          ),
        ],
        recommendations: [],
        createdAt: DateTime.now(),
      );

      notifier.setSession(session);

      final updatedSession = SearchSession(
        id: 'session-1',
        interactions: [
          ...session.interactions,
          Interaction(
            id: 'int-2',
            userInput: 'action',
            assistantPrompt: const InteractionPrompt(
              promptPrefix: "Preference?",
              choices: [
                StructuredChoice(
                  id: 'new',
                  displayText: 'New releases',
                  acceptsTextInput: false,
                ),
              ],
              allowSkip: false,
            ),
            timestamp: DateTime.now(),
          ),
        ],
        recommendations: [],
        createdAt: DateTime.now(),
      );

      when(
        () => mockRepository.addInteraction('session-1', 'action'),
      ).thenAnswer((_) async => updatedSession);

      final future = notifier.addInteraction('session-1', 'action');

      // Should show optimistic update
      expect(notifier.state.isLoading, true);
      expect(notifier.state.value?.interactions.length, 2);

      await future;

      // Should have real data
      expect(notifier.state.value?.interactions.length, 2);
      expect(notifier.state.value?.interactions[1].userInput, 'action');
    });

    test('refreshSession fetches latest session data', () async {
      final mockSession = SearchSession(
        id: 'session-1',
        interactions: [],
        recommendations: [],
        createdAt: DateTime.now(),
      );

      when(
        () => mockRepository.getSearchSession('session-1'),
      ).thenAnswer((_) async => mockSession);

      await notifier.refreshSession('session-1');

      expect(notifier.state.value, mockSession);
      verify(() => mockRepository.getSearchSession('session-1')).called(1);
    });

    test('setSession directly updates state', () {
      final session = SearchSession(
        id: 'session-1',
        interactions: [],
        recommendations: [],
        createdAt: DateTime.now(),
      );

      notifier.setSession(session);

      expect(notifier.state.value, session);
    });

    test('clear resets state to null', () {
      final session = SearchSession(
        id: 'session-1',
        interactions: [],
        recommendations: [],
        createdAt: DateTime.now(),
      );

      notifier.setSession(session);
      expect(notifier.state.value, isNotNull);

      notifier.clear();
      expect(notifier.state.value, isNull);
    });
  });
}
