import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skipthebrowse/main.dart';

import '../test_helper/conversation_screen_tester.dart';
import '../test_helper/home_page_tester.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests', () {
    testWidgets('create a conversation', (tester) async {
      final initialMessage =
          "I'm looking for a movie to watch with my best friend";

      await tester.pumpWidget(const ProviderScope(child: SkipTheBrowse()));
      await tester.pumpAndSettle();

      final homePageTester = HomePageTester(tester);
      expect(homePageTester.isVisible, true);
      expect(homePageTester.title, 'Looking for something to watch?');

      await homePageTester.createConversation(initialMessage);

      final conversationPageTester = ConversationScreenTester(tester);

      await conversationPageTester.waitForIsVisible();
      expect(conversationPageTester.isVisible, true);

      final conversation = conversationPageTester.getConversation();

      expect(conversation[0], initialMessage);
      expect(conversation[1].length, greaterThanOrEqualTo(50));
    });
  });
}
