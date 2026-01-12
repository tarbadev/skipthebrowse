import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/main.dart';

import '../features/conversation/presentation/helpers/conversation_list_screen_tester.dart';
import '../features/conversation/presentation/helpers/conversation_screen_tester.dart';
import '../features/conversation/presentation/helpers/home_screen_tester.dart';
import 'helpers/mock_dio_helper.dart';

void main() {
  group('Integration Tests - Conversation List', () {
    // TODO: Update this test to use search sessions API instead of conversations
    testWidgets(
      'displays conversation list with 3 conversations and navigates to conversation on tap',
      skip: true,
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();

        final mockDioHelper = MockDioHelper();
        final now = DateTime.now();

        // Mock 3 conversations in the list
        mockDioHelper.mockListConversations(
          conversations: [
            {
              'id': 'conversation-1',
              'status': 'active',
              'preview_text': 'I want to watch something funny tonight',
              'created_at': now
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
              'updated_at': now
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
              'message_count': 5,
              'recommendation_count': 0,
            },
            {
              'id': 'conversation-2',
              'status': 'active',
              'preview_text': 'Looking for a good thriller',
              'created_at': now
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
              'updated_at': now
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
              'message_count': 3,
              'recommendation_count': 0,
            },
            {
              'id': 'conversation-3',
              'status': 'active',
              'preview_text': 'Any recommendations for a family movie?',
              'created_at': now
                  .subtract(const Duration(days: 3))
                  .toIso8601String(),
              'updated_at': now
                  .subtract(const Duration(days: 3))
                  .toIso8601String(),
              'message_count': 7,
              'recommendation_count': 0,
            },
          ],
          total: 3,
          limit: 20,
          offset: 0,
        );

        // Mock get conversation for conversation-1 (the one we'll tap)
        mockDioHelper.mockGetConversation(
          conversationId: 'conversation-1',
          messages: [
            {
              'content': 'I want to watch something funny tonight',
              'author': 'user',
            },
            {
              'content': 'Great! What kind of comedy do you prefer?',
              'author': 'assistant',
            },
            {'content': 'Something with slapstick humor', 'author': 'user'},
            {
              'content': 'How about romantic comedies vs pure comedy?',
              'author': 'assistant',
            },
            {'content': 'Pure comedy please', 'author': 'user'},
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

        // Verify conversation list screen is visible
        final searchSessionListTester = SearchSessionListScreenTester(tester);
        await searchSessionListTester.waitForIsVisible();

        // Verify 3 conversations are displayed
        expect(searchSessionListTester.conversationCount, 3);

        // Verify conversation 1 details
        expect(
          searchSessionListTester.getConversationPreviewText(0),
          'I want to watch something funny tonight',
        );
        expect(searchSessionListTester.getConversationMessageCount(0), '5');
        expect(searchSessionListTester.getConversationTimestamp(0), '1h ago');

        // Verify conversation 2 details
        expect(
          searchSessionListTester.getConversationPreviewText(1),
          'Looking for a good thriller',
        );
        expect(searchSessionListTester.getConversationMessageCount(1), '3');
        expect(searchSessionListTester.getConversationTimestamp(1), '1d ago');

        // Verify conversation 3 details
        expect(
          searchSessionListTester.getConversationPreviewText(2),
          'Any recommendations for a family movie?',
        );
        expect(searchSessionListTester.getConversationMessageCount(2), '7');
        expect(searchSessionListTester.getConversationTimestamp(2), '3d ago');

        // Tap on the first conversation
        await searchSessionListTester.tapConversation(0);

        // Verify conversation screen is displayed
        final conversationScreenTester = ConversationScreenTester(tester);
        await conversationScreenTester.waitForIsVisible();
        expect(conversationScreenTester.isVisible, true);

        // Verify the conversation content is displayed
        final conversation = conversationScreenTester.getConversation();
        expect(conversation.length, 5);
        expect(conversation[0], 'I want to watch something funny tonight');
        expect(conversation[1], 'Great! What kind of comedy do you prefer?');
        expect(conversation[2], 'Something with slapstick humor');
        expect(conversation[3], 'How about romantic comedies vs pure comedy?');
        expect(conversation[4], 'Pure comedy please');

        // Tap back button
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        // Verify we're back at the conversation list screen
        expect(searchSessionListTester.isVisible, true);
        expect(searchSessionListTester.conversationCount, 3);
      },
    );
  });
}
