import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/main.dart';

import '../features/conversation/presentation/helpers/conversation_list_screen_tester.dart';
import '../features/conversation/presentation/helpers/home_screen_tester.dart';
import '../features/search/presentation/helpers/search_session_screen_tester.dart';
import 'helpers/mock_dio_helper.dart';

void main() {
  group('Integration Tests - Search Session List', () {
    testWidgets(
      'displays search session list with 3 sessions and navigates to session on tap',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();

        final mockDioHelper = MockDioHelper();
        final now = DateTime.now();

        // Mock 3 search sessions in the list
        mockDioHelper.mockListSearchSessions(
          sessions: [
            {
              'id': 'session-1',
              'initial_message': 'I want to watch something funny tonight',
              'preview_text': 'I want to watch something funny tonight',
              'created_at': now
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
              'updated_at': now
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
              'interaction_count': 5,
              'recommendation_count': 0,
            },
            {
              'id': 'session-2',
              'initial_message': 'Looking for a good thriller',
              'preview_text': 'Looking for a good thriller',
              'created_at': now
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
              'updated_at': now
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
              'interaction_count': 3,
              'recommendation_count': 0,
            },
            {
              'id': 'session-3',
              'initial_message': 'Any recommendations for a family movie?',
              'preview_text': 'Any recommendations for a family movie?',
              'created_at': now
                  .subtract(const Duration(days: 3))
                  .toIso8601String(),
              'updated_at': now
                  .subtract(const Duration(days: 3))
                  .toIso8601String(),
              'interaction_count': 7,
              'recommendation_count': 0,
            },
          ],
          total: 3,
          limit: 50,
          offset: 0,
        );

        // Mock get search session for session-1 (the one we'll tap)
        mockDioHelper.mockGetSearchSession(
          sessionId: 'session-1',
          initialMessage: 'I want to watch something funny tonight',
          interactions: [
            {
              'id': 'int-1',
              'user_input': 'Comedy',
              'assistant_prompt': {
                'prompt_prefix': 'I want to watch...',
                'choices': [
                  {
                    'id': 'comedy',
                    'display_text': 'Comedy',
                    'accepts_text_input': false,
                    'input_placeholder': null,
                  },
                ],
                'allow_skip': false,
              },
              'timestamp': now
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
            },
            {
              'id': 'int-2',
              'user_input': 'Slapstick humor',
              'assistant_prompt': {
                'prompt_prefix': 'What kind of comedy?',
                'choices': [
                  {
                    'id': 'slapstick',
                    'display_text': 'Slapstick humor',
                    'accepts_text_input': false,
                    'input_placeholder': null,
                  },
                ],
                'allow_skip': false,
              },
              'timestamp': now
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
            },
            {
              'id': 'int-3',
              'user_input': null,
              'assistant_prompt': {
                'prompt_prefix': 'I prefer...',
                'choices': [
                  {
                    'id': 'romantic',
                    'display_text': 'Romantic comedy',
                    'accepts_text_input': false,
                    'input_placeholder': null,
                  },
                  {
                    'id': 'pure',
                    'display_text': 'Pure comedy',
                    'accepts_text_input': false,
                    'input_placeholder': null,
                  },
                ],
                'allow_skip': false,
              },
              'timestamp': now
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
            },
          ],
          timestamp: now.subtract(const Duration(hours: 2)),
        );

        // Pump the app
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dioProvider.overrideWithValue(mockDioHelper.dio),
              sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            ],
            child: const SkipTheBrowse(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify we're on home screen
        final homeScreenTester = HomeScreenTester(tester);
        expect(homeScreenTester.isVisible, true);

        // Tap the history button
        await homeScreenTester.tapHistoryButton();

        // Verify search session list screen is visible
        final searchSessionListTester = SearchSessionListScreenTester(tester);
        await searchSessionListTester.waitForIsVisible();

        // Verify 3 search sessions are displayed
        expect(searchSessionListTester.conversationCount, 3);

        // Verify session 1 details
        expect(
          searchSessionListTester.getConversationPreviewText(0),
          'I want to watch something funny tonight',
        );
        expect(searchSessionListTester.getInteractionCount(0), 5);
        expect(searchSessionListTester.getConversationTimestamp(0), '1h ago');

        // Verify session 2 details
        expect(
          searchSessionListTester.getConversationPreviewText(1),
          'Looking for a good thriller',
        );
        expect(searchSessionListTester.getInteractionCount(1), 3);
        expect(searchSessionListTester.getConversationTimestamp(1), '1d ago');

        // Verify session 3 details
        expect(
          searchSessionListTester.getConversationPreviewText(2),
          'Any recommendations for a family movie?',
        );
        expect(searchSessionListTester.getInteractionCount(2), 7);
        expect(searchSessionListTester.getConversationTimestamp(2), '3d ago');

        // Tap on the first session
        await searchSessionListTester.tapConversation(0);

        // Verify search session screen is displayed
        final searchSessionScreenTester = SearchSessionScreenTester(tester);
        await searchSessionScreenTester.waitForIsVisible();
        expect(searchSessionScreenTester.isVisible, true);

        // Verify the session content is displayed
        final session = searchSessionScreenTester.getSearchSession();
        expect(session.length, greaterThanOrEqualTo(3));
        expect(session[0], 'I want to watch something funny tonight');
        expect(session[1], 'I want to watch...');
        expect(session[2], 'Comedy');

        // Tap back button
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        // Verify we're back at the search session list screen
        expect(searchSessionListTester.isVisible, true);
        expect(searchSessionListTester.conversationCount, 3);
      },
    );
  });
}
