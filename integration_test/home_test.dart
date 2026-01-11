import 'package:flutter_test/flutter_test.dart';

import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';
import '../test/features/search/presentation/helpers/search_session_screen_tester.dart';
import 'test_helper.dart';

void main() {
  group('Home Tests', () {
    testWidgets('create a searchSession', (tester) async {
      final initialMessage =
          "I'm looking for a movie to watch with my best friend";

      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);
      expect(homeScreenTester.title, 'Looking for something to watch?');

      await homeScreenTester.createSearchSession(initialMessage);
      await tester.pumpAndSettle();

      final searchSessionPageTester = SearchSessionScreenTester(tester);

      await searchSessionPageTester.waitForIsVisible();
      expect(searchSessionPageTester.isVisible, true);

      var searchSession = searchSessionPageTester.getSearchSession();

      expect(searchSession[0], initialMessage);
      expect(searchSession[1].length, greaterThanOrEqualTo(10));

      // Select the "Comedy" choice (assuming it's one of the choices returned by the LLM)
      const choiceText = 'Comedy';
      await searchSessionPageTester.addMessage(choiceText);
      await tester.pumpAndSettle();

      searchSession = searchSessionPageTester.getSearchSession();
      expect(searchSession[2], choiceText);
      expect(searchSession[3].length, greaterThanOrEqualTo(10));
    });
  });
}
