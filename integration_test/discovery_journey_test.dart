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
      robot.expectAtHome();

      const query = 'I want to watch a space movie';
      await robot.searchFor(query);

      await robot.waitForAIResponse();
      robot.expectTextVisible(query);

      expect(robot.isAIResponding(), true);

      await robot.navigateBack();
      robot.expectAtHome();
    });
  });
}
