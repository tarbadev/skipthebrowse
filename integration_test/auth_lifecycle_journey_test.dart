import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Lifecycle Journey (Real Backend)', () {
    testWidgets(
      'Full auth flow: Anonymous -> Account Settings -> Registration UI',
      (tester) async {
        final robot = AppRobot(tester);

        await robot.bootApp();
        await robot.expectAtHome();

        await robot.goToAccount();
        await robot.expectAtAccountSettings();
        await robot.expectAnonymousUserViewVisible();

        await robot.tapCreateAccount();
        await robot.expectAtUpgradeAccountScreen();

        await robot.navigateBack();
        await robot.navigateBack();
        await robot.expectAtHome();
      },
    );
  });
}
