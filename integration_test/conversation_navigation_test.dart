import 'package:flutter_test/flutter_test.dart';

import '../test/features/conversation/presentation/helpers/conversation_list_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';
import '../test/features/search/presentation/helpers/search_session_screen_tester.dart';
import 'test_helper.dart';

void main() {
  group('Conversation Navigation E2E Tests', () {
    testWidgets('can create conversation after visiting conversation list', (
      tester,
    ) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      final searchSessionScreenTester = SearchSessionScreenTester(tester);
      final searchSessionListTester = SearchSessionListScreenTester(tester);

      // Step 1: Verify we're on home screen
      expect(homeScreenTester.isVisible, true);

      // Step 2: Create first conversation
      final firstMessage = "I want to watch a comedy";
      await homeScreenTester.createSearchSession(firstMessage);

      // Step 3: Verify conversation screen is displayed (waitForIsVisible will handle pumping)
      await searchSessionScreenTester.waitForIsVisible();
      expect(searchSessionScreenTester.isVisible, true);
      final firstConversation = searchSessionScreenTester.getSearchSession();
      expect(firstConversation[0], firstMessage);
      expect(firstConversation[1].length, greaterThanOrEqualTo(10));

      // Step 4: Go back to home screen
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 5: Navigate to conversation list
      await homeScreenTester.tapHistoryButton();
      await searchSessionListTester.waitForIsVisible();
      expect(homeScreenTester.isVisible, false);
      expect(searchSessionListTester.isVisible, true);
      expect(
        searchSessionListTester.conversationCount,
        greaterThanOrEqualTo(1),
      );

      // Tap first conversation in list
      await searchSessionListTester.tapConversation(0);
      await searchSessionScreenTester.waitForIsVisible();
      expect(searchSessionScreenTester.isVisible, true);

      // Back to list
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(searchSessionListTester.isVisible, true);

      // Step 6: Go back to home screen
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 7: Create second conversation (this is where the bug might occur)
      final secondMessage = "Looking for a thriller";
      await homeScreenTester.createSearchSession(secondMessage);

      // Step 8: Verify second conversation screen is displayed (waitForIsVisible will handle pumping)
      await searchSessionScreenTester.waitForIsVisible();
      expect(searchSessionScreenTester.isVisible, true);
      final secondConversation = searchSessionScreenTester.getSearchSession();
      expect(secondConversation[0], secondMessage);
      expect(secondConversation[1].length, greaterThanOrEqualTo(10));
    });
  });
}
