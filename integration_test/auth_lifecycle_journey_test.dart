import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Lifecycle Journey (Real Backend)', () {
    testWidgets('Full auth flow: Anonymous -> Account Settings -> Logout', (
      tester,
    ) async {
      final robot = AppRobot(tester);

      await robot.bootApp();
      expect(find.byKey(const Key('home_page_title')), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline).last);
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Sync Your Data'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Since we are anonymous, the title will be 'Upgrade Account'
      expect(find.text('Upgrade Account'), findsWidgets);

      await robot.navigateBack();
      await robot.navigateBack();
      expect(find.byKey(const Key('home_page_title')), findsOneWidget);
    });
  });
}
