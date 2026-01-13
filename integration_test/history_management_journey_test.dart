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

        final uniqueTerm = "testTerm${DateTime.now().millisecondsSinceEpoch}";
        await robot.searchFor("I want to watch $uniqueTerm films");
        await robot.waitForAIResponse();

        await robot.navigateBack();
        await robot.goToHistory();

        await robot.waitForHistoryItems();
        robot.expectTextVisible(uniqueTerm);

        await robot.searchInHistory(uniqueTerm);
        robot.expectTextVisible(uniqueTerm);

        await robot.openHistoryItem(uniqueTerm);
        await robot.waitForAIResponse();

        robot.expectTextVisible(uniqueTerm);

        await robot.navigateBack();
        await robot.navigateBack();
        robot.expectAtHome();
      },
    );
  });
}
