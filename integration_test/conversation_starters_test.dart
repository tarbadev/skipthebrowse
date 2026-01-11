import 'package:flutter_test/flutter_test.dart';

import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';
import '../test/features/search/presentation/helpers/search_session_screen_tester.dart';
import 'test_helper.dart';

void main() {
  group('Conversation Starters Tests', () {
    testWidgets('searchSession starter chips are visible on home screen', (
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

    testWidgets('tapping first starter creates searchSession', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);

      final starterText = "I want something thrilling to watch";
      await homeScreenTester.tapSearchSessionStarter(starterText);

      final searchSessionScreenTester = SearchSessionScreenTester(tester);
      await searchSessionScreenTester.waitForIsVisible();
      expect(searchSessionScreenTester.isVisible, true);

      final searchSession = searchSessionScreenTester.getSearchSession();
      expect(searchSession[0], starterText);
      expect(searchSession[1].length, greaterThanOrEqualTo(10));
    });

    testWidgets('tapping second starter creates searchSession', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);

      final starterText = "Looking for a comedy series to binge";
      await homeScreenTester.tapSearchSessionStarter(starterText);

      final searchSessionScreenTester = SearchSessionScreenTester(tester);
      await searchSessionScreenTester.waitForIsVisible();
      expect(searchSessionScreenTester.isVisible, true);

      final searchSession = searchSessionScreenTester.getSearchSession();
      expect(searchSession[0], starterText);
      expect(searchSession[1].length, greaterThanOrEqualTo(10));
    });

    testWidgets('tapping third starter creates searchSession', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);

      final starterText = "Recommend me something like Inception";
      await homeScreenTester.tapSearchSessionStarter(starterText);

      final searchSessionScreenTester = SearchSessionScreenTester(tester);
      await searchSessionScreenTester.waitForIsVisible();
      expect(searchSessionScreenTester.isVisible, true);

      final searchSession = searchSessionScreenTester.getSearchSession();
      expect(searchSession[0], starterText);
      expect(searchSession[1].length, greaterThanOrEqualTo(10));
    });
  });
}
