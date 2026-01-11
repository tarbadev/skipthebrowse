import 'package:flutter_test/flutter_test.dart';

import '../test/features/conversation/presentation/helpers/conversation_list_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';
import '../test/features/search/presentation/helpers/search_session_screen_tester.dart';
import 'test_helper.dart';

void main() {
  group('Search Session History E2E Tests', () {
    testWidgets('can view search sessions in history', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      final searchSessionConversationStarter = SearchSessionScreenTester(
        tester,
      );
      final searchSessionListTester = SearchSessionListScreenTester(tester);

      // Step 1: Create first search session
      expect(homeScreenTester.isVisible, true);
      final firstMessage = "I want to watch action movies";
      await homeScreenTester.createSearchSession(firstMessage);
      await searchSessionConversationStarter.waitForIsVisible();
      expect(searchSessionConversationStarter.isVisible, true);

      // Go back to home
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 2: Create second search session
      final secondMessage = "Looking for comedy shows";
      await homeScreenTester.createSearchSession(secondMessage);
      await searchSessionConversationStarter.waitForIsVisible();
      expect(searchSessionConversationStarter.isVisible, true);

      // Go back to home
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 3: Navigate to search session list
      await homeScreenTester.tapHistoryButton();
      await searchSessionListTester.waitForIsVisible();
      expect(searchSessionListTester.isVisible, true);

      // Step 4: Verify we have at least 2 search sessions
      final totalSessions = searchSessionListTester.conversationCount;
      expect(totalSessions, greaterThanOrEqualTo(2));

      // Step 5: Verify the sessions contain the expected preview text
      // Most recent session should be at top (secondMessage)
      final firstSessionPreview = searchSessionListTester
          .getConversationPreviewText(0);
      final secondSessionPreview = searchSessionListTester
          .getConversationPreviewText(1);

      // One of the top two sessions should contain our messages
      final previews = [firstSessionPreview, secondSessionPreview];
      expect(
        previews.any((preview) => preview.toLowerCase().contains('comedy')),
        true,
        reason: 'Expected to find comedy session in recent sessions',
      );
      expect(
        previews.any((preview) => preview.toLowerCase().contains('action')),
        true,
        reason: 'Expected to find action session in recent sessions',
      );

      // Step 6: Verify each session has interaction count
      expect(searchSessionListTester.getInteractionCount(0), greaterThan(0));
      expect(searchSessionListTester.getInteractionCount(1), greaterThan(0));
    });

    testWidgets('can tap on session to open it', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      final searchSessionConversationStarter = SearchSessionScreenTester(
        tester,
      );
      final searchSessionListTester = SearchSessionListScreenTester(tester);

      // Create a search session with a unique identifier
      expect(homeScreenTester.isVisible, true);
      final uniqueTerm =
          "zzztestunique${DateTime.now().millisecondsSinceEpoch}";
      final message = "I want $uniqueTerm recommendations";
      await homeScreenTester.createSearchSession(message);
      await searchSessionConversationStarter.waitForIsVisible();

      // Go back to home and then to session list
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await homeScreenTester.tapHistoryButton();
      await searchSessionListTester.waitForIsVisible();

      // Verify the session is at the top (most recent)
      expect(
        searchSessionListTester.conversationCount,
        greaterThanOrEqualTo(1),
      );

      final topSessionPreview = searchSessionListTester
          .getConversationPreviewText(0);
      expect(
        topSessionPreview.toLowerCase().contains(uniqueTerm.toLowerCase()),
        true,
        reason: 'Expected most recent session to contain our unique term',
      );

      // Tap on the session to open it
      await searchSessionListTester.tapConversation(0);
      await searchSessionConversationStarter.waitForIsVisible();

      // Verify we're on the correct session screen
      expect(searchSessionConversationStarter.isVisible, true);
      final sessionMessages = searchSessionConversationStarter
          .getSearchSession();
      expect(sessionMessages[0], message);
    });
  });
}
