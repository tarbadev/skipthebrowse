import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/core/network/dio_provider.dart';
import 'package:skipthebrowse/main.dart';

import '../features/conversation/presentation/helpers/home_screen_tester.dart';
import '../features/search/presentation/helpers/search_session_screen_tester.dart';
import 'helpers/mock_dio_helper.dart';

void main() {
  group('Integration Tests - Home Screen', () {
    testWidgets(
      'creates a search session and navigates to search session screen',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();

        final mockDioHelper = MockDioHelper();
        final initialMessage = "I'm looking for a movie to watch";
        final promptPrefix = 'What genre are you interested in?';
        final sessionId = 'test-session-id';
        final timestamp = DateTime(2025, 1, 1);

        mockDioHelper.mockCreateSearchSession(
          sessionId: sessionId,
          initialMessage: initialMessage,
          interactions: [
            {
              'id': 'interaction-1',
              'user_input': null,
              'assistant_prompt': {
                'prompt_prefix': promptPrefix,
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
                    'id': 'drama',
                    'display_text': 'Drama',
                    'accepts_text_input': false,
                    'input_placeholder': null,
                  },
                ],
                'allow_skip': false,
              },
              'timestamp': timestamp.toIso8601String(),
            },
          ],
          timestamp: timestamp,
        );

        mockDioHelper.mockGetSearchSession(
          sessionId: sessionId,
          initialMessage: initialMessage,
          interactions: [
            {
              'id': 'interaction-1',
              'user_input': null,
              'assistant_prompt': {
                'prompt_prefix': promptPrefix,
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
                    'id': 'drama',
                    'display_text': 'Drama',
                    'accepts_text_input': false,
                    'input_placeholder': null,
                  },
                ],
                'allow_skip': false,
              },
              'timestamp': timestamp.toIso8601String(),
            },
          ],
          timestamp: timestamp,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              baseDioProvider.overrideWithValue(mockDioHelper.dio),
              dioProvider.overrideWithValue(mockDioHelper.dio),
              sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            ],
            child: const SkipTheBrowse(),
          ),
        );
        await tester.pumpAndSettle();

        final homeScreenTester = HomeScreenTester(tester);
        expect(homeScreenTester.isVisible, true);
        expect(homeScreenTester.title, 'Looking for something to watch?');

        await homeScreenTester.createSearchSession(initialMessage);
        await tester.pumpAndSettle();

        final searchSessionScreenTester = SearchSessionScreenTester(tester);
        await searchSessionScreenTester.waitForIsVisible();
        expect(searchSessionScreenTester.isVisible, true);

        final session = searchSessionScreenTester.getSearchSession();
        expect(session[0], initialMessage);
        expect(session[1], promptPrefix);
      },
    );
  });
}
