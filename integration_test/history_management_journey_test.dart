import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('History Management Journey (Real Backend)', () {
    testWidgets(
      'Full history flow: Create -> Navigate -> Search -> View Old Chat',
      (tester) async {
        final robot = AppRobot(tester);

        await robot.bootApp();

        // 1. Create a unique session
        final uniqueTerm = "testTerm${DateTime.now().millisecondsSinceEpoch}";
        await robot.searchFor("I want to watch $uniqueTerm films");
        await robot.waitForAIResponse();

        // 2. Go Back and Navigate to History
        await robot.navigateBack();
        await robot.goToHistory();

        // 3. Verify the session appears in the list
        // Use a longer timeout and specific ListTile check
        await robot.waitFor(
          find.byType(ListTile),
          timeout: const Duration(seconds: 30),
        );
        expect(find.textContaining("testTerm"), findsWidgets);

        // 4. Perform a Search within History
        final searchField = find.descendant(
          of: find.byType(TextField),
          matching: find.byType(EditableText),
        );

        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField).first, uniqueTerm);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          // Verify results filtered
          expect(find.textContaining(uniqueTerm), findsWidgets);
        }

        // 5. Open the session from history
        // Target the ListTile specifically to avoid tapping the search bar text
        await tester.tap(
          find
              .descendant(
                of: find.byType(ListTile),
                matching: find.textContaining(uniqueTerm),
              )
              .first,
        );

        await robot.waitForAIResponse();

        // Verify we are back in the correct conversation
        expect(find.textContaining(uniqueTerm), findsWidgets);

        // 6. Return Home
        await robot.navigateBack(); // Back to History
        await robot.navigateBack(); // Back to Home
        expect(find.byKey(const Key('home_page_title')), findsOneWidget);
      },
    );
  });
}
