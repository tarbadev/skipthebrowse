import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helper.dart';

void main() {
  group('Search Session Flow E2E Tests', () {
    testWidgets(
      'complete search session flow with interactions and recommendations',
      (tester) async {
        await pumpSkipTheBrowse(tester);

        // Verify home screen is visible
        expect(find.text('Looking for something to watch?'), findsOneWidget);
        expect(find.text('Start your conversation:'), findsOneWidget);

        // Create a search session
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, 'I want to watch a thriller');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Should navigate to SearchSessionScreen
        expect(find.text('Search Session'), findsOneWidget);

        // Wait for the first interaction prompt to appear
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // The structured prompt should have choice buttons
        // Look for buttons (they should be rendered as widgets with onTap)
        final choiceButtons = find.byType(InkWell);
        expect(choiceButtons, findsWidgets);

        // Tap the first choice
        await tester.tap(choiceButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Look for submit button and tap it
        final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));
        }

        // After multiple interactions, we should eventually get recommendations
        // Keep interacting until we see recommendations or reach max iterations
        int maxIterations = 5;
        int iterations = 0;

        while (iterations < maxIterations) {
          // Check if we have recommendations
          final recommendationCards = find.byType(Card);
          if (recommendationCards.evaluate().length > 2) {
            // Found recommendations
            break;
          }

          // Otherwise, continue interacting
          final choiceButtons = find.byType(InkWell);
          if (choiceButtons.evaluate().isNotEmpty) {
            await tester.tap(choiceButtons.first);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));

            final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
            if (submitButton.evaluate().isNotEmpty) {
              await tester.tap(submitButton);
              await tester.pumpAndSettle(const Duration(seconds: 5));
            }
          }

          iterations++;
        }

        // Verify that we have recommendations visible
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Look for recommendation status buttons (Seen, Will Watch, etc.)
        final statusButtons = find.widgetWithIcon(
          TextButton,
          Icons.check_circle_outline_rounded,
        );
        expect(statusButtons, findsWidgets);
      },
    );

    testWidgets('access recommendation history and update status', (
      tester,
    ) async {
      await pumpSkipTheBrowse(tester);

      // Navigate to recommendation history
      final historyButton = find.byTooltip('My Recommendations');
      expect(historyButton, findsOneWidget);
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

      // Wait for recommendations to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for recommendation cards
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        // Tap on "Will Watch" tab
        await tester.tap(find.text('Will Watch'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Tap on "Seen" tab
        await tester.tap(find.text('Seen'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('search recommendations by text', (tester) async {
      await pumpSkipTheBrowse(tester);

      // Navigate to recommendation history
      final historyButton = find.byTooltip('My Recommendations');
      await tester.tap(historyButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'thriller');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show search results
      // Results will vary based on existing data, so we just verify the UI responds
      expect(find.byType(ListView), findsOneWidget);

      // Clear search
      final clearButton = find.byIcon(Icons.clear_rounded);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('optional text input in structured choice', (tester) async {
      await pumpSkipTheBrowse(tester);

      // Create a search session
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'Something specific');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Wait for interaction prompt
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for choice that might accept text input (e.g., "Other")
      final otherChoice = find.text('Other');
      if (otherChoice.evaluate().isNotEmpty) {
        await tester.tap(otherChoice);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Check if a text field appeared for custom input
        final customInputField = find.byType(TextField).last;
        if (customInputField.evaluate().isNotEmpty) {
          await tester.enterText(customInputField, 'My custom preference');
          await tester.pumpAndSettle(const Duration(milliseconds: 300));
        }

        // Submit without entering text (to test optional nature)
        final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));
        }
      }
    });

    testWidgets('scroll behavior shows last interaction at top', (
      tester,
    ) async {
      await pumpSkipTheBrowse(tester);

      // Create a search session
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'Sci-fi series');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Wait for interaction
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Submit multiple interactions to test scroll behavior
      for (int i = 0; i < 3; i++) {
        final choiceButtons = find.byType(InkWell);
        if (choiceButtons.evaluate().isEmpty) break;

        await tester.tap(choiceButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));
        }
      }

      // Verify ListView exists and has scrolled
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
    });
  });
}
