import 'package:flutter_test/flutter_test.dart';

import '../test/features/conversation/presentation/helpers/conversation_list_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/conversation_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';
import 'test_helper.dart';

void main() {
  group('Conversation Search E2E Tests', () {
    testWidgets('can search conversations and see matching results', (
      tester,
    ) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      final conversationScreenTester = ConversationScreenTester(tester);
      final conversationListTester = ConversationListScreenTester(tester);

      // Step 1: Create first conversation with "action" keyword
      expect(homeScreenTester.isVisible, true);
      final firstMessage = "I want to watch action movies";
      await homeScreenTester.createSearchSession(firstMessage);
      await conversationScreenTester.waitForIsVisible();
      expect(conversationScreenTester.isVisible, true);

      // Go back to home
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 2: Create second conversation with "comedy" keyword
      final secondMessage = "Looking for comedy shows";
      await homeScreenTester.createSearchSession(secondMessage);
      await conversationScreenTester.waitForIsVisible();
      expect(conversationScreenTester.isVisible, true);

      // Go back to home
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 3: Navigate to conversation list
      await homeScreenTester.tapHistoryButton();
      await conversationListTester.waitForIsVisible();
      expect(conversationListTester.isVisible, true);
      expect(conversationListTester.hasSearchBar, true);

      // Verify we have at least 2 conversations
      final totalConversations = conversationListTester.conversationCount;
      expect(totalConversations, greaterThanOrEqualTo(2));

      // Step 4: Search for "action" - should find first conversation
      await conversationListTester.enterSearchQuery('action');
      expect(conversationListTester.conversationCount, greaterThanOrEqualTo(1));

      // Verify the matched content contains our action conversation
      final firstMatchedContent = conversationListTester.getMatchedContent(0);
      expect(firstMatchedContent, isNotNull);
      expect(firstMatchedContent!.toLowerCase(), contains('action'));

      // Step 5: Search for "comedy" - should find second conversation
      await conversationListTester.clearSearch();
      await conversationListTester.enterSearchQuery('comedy');
      expect(conversationListTester.conversationCount, greaterThanOrEqualTo(1));

      // Verify the matched content contains our comedy conversation
      final comedyMatchedContent = conversationListTester.getMatchedContent(0);
      expect(comedyMatchedContent, isNotNull);
      expect(comedyMatchedContent!.toLowerCase(), contains('comedy'));

      // Step 6: Search for non-existent keyword - should show no results
      await conversationListTester.clearSearch();
      await conversationListTester.enterSearchQuery('zzznonexistent');
      expect(conversationListTester.conversationCount, 0);
      expect(conversationListTester.hasNoResultsMessage, true);

      // Step 7: Clear search - should show all conversations again
      await conversationListTester.clearSearch();
      expect(conversationListTester.conversationCount, totalConversations);
      expect(conversationListTester.hasNoResultsMessage, false);
    });

    testWidgets('can tap on search result to open conversation', (
      tester,
    ) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      final conversationScreenTester = ConversationScreenTester(tester);
      final conversationListTester = ConversationListScreenTester(tester);

      // Create a conversation with a unique search term
      expect(homeScreenTester.isVisible, true);
      final uniqueTerm =
          "zzztestunique${DateTime.now().millisecondsSinceEpoch}";
      final message = "I want $uniqueTerm recommendations";
      await homeScreenTester.createSearchSession(message);
      await conversationScreenTester.waitForIsVisible();

      // Go back to home and then to conversation list
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await homeScreenTester.tapHistoryButton();
      await conversationListTester.waitForIsVisible();

      // Search for the unique term (should only find this conversation)
      await conversationListTester.enterSearchQuery(uniqueTerm);
      expect(conversationListTester.conversationCount, 1);

      // Verify matched content contains the unique term
      final matchedContent = conversationListTester.getMatchedContent(0);
      expect(matchedContent, isNotNull);
      expect(matchedContent!.toLowerCase(), contains(uniqueTerm.toLowerCase()));

      // Tap on the search result
      await conversationListTester.tapConversation(0);
      await conversationScreenTester.waitForIsVisible();

      // Verify we're on the correct conversation screen
      expect(conversationScreenTester.isVisible, true);
      final conversation = conversationScreenTester.getConversation();
      expect(conversation[0], message);
    });
  });
}
