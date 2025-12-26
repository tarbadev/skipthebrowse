import 'package:flutter_test/flutter_test.dart';

import '../test/features/conversation/presentation/helpers/conversation_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';
import 'test_helper.dart';

void main() {
  group('Conversation Starters Tests', () {
    testWidgets('conversation starter chips are visible on home screen', (
      tester,
    ) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);

      expect(
        homeScreenTester.conversationStarterExists(
          "I want something thrilling to watch",
        ),
        true,
      );
      expect(
        homeScreenTester.conversationStarterExists(
          "Looking for a comedy series to binge",
        ),
        true,
      );
      expect(
        homeScreenTester.conversationStarterExists(
          "Recommend me something like Inception",
        ),
        true,
      );
    });

    testWidgets('tapping first starter creates conversation', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);

      final starterText = "I want something thrilling to watch";
      await homeScreenTester.tapConversationStarter(starterText);

      final conversationPageTester = ConversationScreenTester(tester);
      await conversationPageTester.waitForIsVisible();
      expect(conversationPageTester.isVisible, true);

      final conversation = conversationPageTester.getConversation();
      expect(conversation[0], starterText);
      expect(conversation[1].length, greaterThanOrEqualTo(50));
    });

    testWidgets('tapping second starter creates conversation', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);

      final starterText = "Looking for a comedy series to binge";
      await homeScreenTester.tapConversationStarter(starterText);

      final conversationPageTester = ConversationScreenTester(tester);
      await conversationPageTester.waitForIsVisible();
      expect(conversationPageTester.isVisible, true);

      final conversation = conversationPageTester.getConversation();
      expect(conversation[0], starterText);
      expect(conversation[1].length, greaterThanOrEqualTo(50));
    });

    testWidgets('tapping third starter creates conversation', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);

      final starterText = "Recommend me something like Inception";
      await homeScreenTester.tapConversationStarter(starterText);

      final conversationPageTester = ConversationScreenTester(tester);
      await conversationPageTester.waitForIsVisible();
      expect(conversationPageTester.isVisible, true);

      final conversation = conversationPageTester.getConversation();
      expect(conversation[0], starterText);
      expect(conversation[1].length, greaterThanOrEqualTo(50));
    });
  });
}
