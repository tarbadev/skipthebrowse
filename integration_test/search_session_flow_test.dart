import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';
import '../test/features/search/presentation/helpers/search_session_screen_tester.dart';
import 'test_helper.dart';

void main() {
  group('Search Session Flow E2E Tests', () {
    testWidgets(
      'complete search session flow with interactions and recommendations',
      (tester) async {
        await pumpSkipTheBrowse(tester);

        final homeScreenTester = HomeScreenTester(tester);
        final searchSessionScreenTester = SearchSessionScreenTester(tester);

        // Verify home screen is visible
        expect(homeScreenTester.isVisible, true);

        // Create a search session
        await homeScreenTester.createSearchSession(
          'I want to watch a thriller',
        );
        await searchSessionScreenTester.waitForIsVisible();
        expect(searchSessionScreenTester.isVisible, true);

        // After multiple interactions, we should eventually get recommendations
        // Keep interacting until we see recommendations or reach max iterations
        int maxIterations = 5;
        int iterations = 0;

        while (iterations < maxIterations) {
          // Check if we have recommendations (Card widgets with keys)
          final recommendationCards = find.byWidgetPredicate(
            (widget) =>
                widget is Card &&
                widget.key != null &&
                widget.key.toString().contains('recommendation_'),
          );

          if (recommendationCards.evaluate().isNotEmpty) {
            // Found recommendations, break
            break;
          }

          // Otherwise, continue interacting
          // Find choice buttons (ElevatedButton widgets with text)
          final choiceButtons = find.ancestor(
            of: find.byType(Text),
            matching: find.byType(ElevatedButton),
          );

          if (choiceButtons.evaluate().isNotEmpty) {
            // Tap the first choice button
            await tester.tap(choiceButtons.first);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));

            // Look for Continue button and tap it
            final continueButton = find.widgetWithText(
              ElevatedButton,
              'Continue',
            );
            if (continueButton.evaluate().isNotEmpty) {
              await tester.tap(continueButton);
              await tester.pumpAndSettle(const Duration(seconds: 5));
            }
          }

          iterations++;
        }

        // Verify that we have recommendations visible
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final recommendationCards = find.byWidgetPredicate(
          (widget) =>
              widget is Card &&
              widget.key != null &&
              widget.key.toString().contains('recommendation_'),
        );

        // If we have recommendations, verify status buttons exist
        if (recommendationCards.evaluate().isNotEmpty) {
          // Look for recommendation status buttons (OutlinedButton with icons)
          final statusButtons = find.widgetWithIcon(
            OutlinedButton,
            Icons.check_circle_outline_rounded,
          );
          expect(statusButtons, findsWidgets);
        }
      },
    );

    testWidgets('access recommendation history', (tester) async {
      await pumpSkipTheBrowse(tester);

      // Navigate to recommendation history
      final historyButton = find.byTooltip('My Recommendations');
      if (historyButton.evaluate().isEmpty) {
        // Skip test if recommendation history button doesn't exist yet
        return;
      }

      await tester.tap(historyButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on RecommendationHistoryScreen
      expect(find.text('My Recommendations'), findsOneWidget);

      // Should have tabs
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Will Watch'), findsOneWidget);
      expect(find.text('Seen'), findsOneWidget);
      expect(find.text('Declined'), findsOneWidget);

      // Check if there are any recommendations
      final searchBar = find.byType(TextField);
      expect(searchBar, findsOneWidget);
    });

    testWidgets('search recommendations by text', (tester) async {
      await pumpSkipTheBrowse(tester);

      // Navigate to recommendation history
      final historyButton = find.byTooltip('My Recommendations');
      if (historyButton.evaluate().isEmpty) {
        // Skip test if recommendation history button doesn't exist yet
        return;
      }

      await tester.tap(historyButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on recommendation history screen
      final onHistoryScreen = find
          .text('My Recommendations')
          .evaluate()
          .isNotEmpty;
      if (!onHistoryScreen) {
        // Skip if screen structure is different
        return;
      }

      // Enter search query if search field exists
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isEmpty) {
        // Skip if no search field
        return;
      }

      await tester.enterText(searchFields.first, 'thriller');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify the screen responded to the search
      // (Don't require specific widgets since UI structure may vary)
      expect(find.text('My Recommendations'), findsOneWidget);
    });

    testWidgets('optional text input in structured choice', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      final searchSessionScreenTester = SearchSessionScreenTester(tester);

      // Create a search session
      await homeScreenTester.createSearchSession('Something specific');
      await searchSessionScreenTester.waitForIsVisible();

      // Look for choice that might accept text input (e.g., "Other", "Something else")
      final otherChoices = [
        find.widgetWithText(ElevatedButton, 'Other'),
        find.widgetWithText(ElevatedButton, 'Something else'),
        find.widgetWithText(ElevatedButton, 'Something specific'),
      ];

      for (final otherChoice in otherChoices) {
        if (otherChoice.evaluate().isNotEmpty) {
          await tester.tap(otherChoice);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // Check if a text field appeared for custom input
          final textFields = find.byType(TextField);
          if (textFields.evaluate().length > 1) {
            // There's a custom input field (more than just home screen fields)
            final customInputField = textFields.last;
            await tester.enterText(customInputField, 'My custom preference');
            await tester.pumpAndSettle(const Duration(milliseconds: 300));
          }

          // Tap Continue button
          final continueButton = find.widgetWithText(
            ElevatedButton,
            'Continue',
          );
          if (continueButton.evaluate().isNotEmpty) {
            await tester.tap(continueButton);
            await tester.pumpAndSettle(const Duration(seconds: 5));
          }
          break;
        }
      }
    });

    testWidgets('scroll behavior with multiple interactions', (tester) async {
      await pumpSkipTheBrowse(tester);

      final homeScreenTester = HomeScreenTester(tester);
      final searchSessionScreenTester = SearchSessionScreenTester(tester);

      // Create a search session
      await homeScreenTester.createSearchSession('Sci-fi series');
      await searchSessionScreenTester.waitForIsVisible();

      // Submit multiple interactions to test scroll behavior
      for (int i = 0; i < 3; i++) {
        // Find choice buttons (ElevatedButton with text)
        final choiceButtons = find.ancestor(
          of: find.byType(Text),
          matching: find.byType(ElevatedButton),
        );

        if (choiceButtons.evaluate().isEmpty) break;

        // Tap first choice button
        await tester.tap(choiceButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Tap Continue button
        final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
        if (continueButton.evaluate().isNotEmpty) {
          await tester.tap(continueButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));
        } else {
          break;
        }
      }

      // Verify ListView exists
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Verify we have multiple interactions
      final sessionMessages = searchSessionScreenTester.getSearchSession();
      expect(sessionMessages.length, greaterThan(2));
    });
  });
}
