import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Discovery Smoke Test (Real Backend)', () {
    testWidgets('Verify backend connectivity and initial conversation flow', (
      tester,
    ) async {
      final robot = AppRobot(tester);

      await robot.bootApp();

      // 1. Verify Home Screen loads
      expect(find.byKey(const Key('home_page_title')), findsOneWidget);

      // 2. Start a custom conversation
      const query = 'I want to watch a space movie';
      await robot.searchFor(query);

      // 3. Wait for the FIRST AI response (Smoke check for API + AI processing)
      await robot.waitForAIResponse();
      expect(find.text(query), findsOneWidget);

      // 4. Verify that the AI actually returned something (either text or a choice)
      // This confirms the backend pipeline is healthy.
      final responseFound =
          find.byType(SelectableText).evaluate().isNotEmpty ||
          find.byType(ElevatedButton).evaluate().isNotEmpty;
      expect(
        responseFound,
        true,
        reason: 'Backend should return a message or choices',
      );

      // 5. Navigation: Ensure we can get back to safety
      await robot.navigateBack();
      expect(find.byKey(const Key('home_page_title')), findsOneWidget);
    });
  });
}
