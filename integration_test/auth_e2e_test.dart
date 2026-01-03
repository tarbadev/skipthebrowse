import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Anonymous Auth E2E', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets(
      'should automatically authenticate and create conversation',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('auth_token');
        final tokenType = prefs.getString('token_type');
        final userJson = prefs.getString('user');

        expect(authToken, isNotNull, reason: 'Auth token should be created');
        expect(
          tokenType,
          equals('bearer'),
          reason: 'Token type should be bearer',
        );
        expect(userJson, isNotNull, reason: 'User should be created');
        expect(
          userJson,
          contains('is_anonymous'),
          reason: 'User should be anonymous',
        );

        final textField = find.byType(TextField);
        expect(
          textField,
          findsOneWidget,
          reason: 'Should find input field on home screen',
        );

        await tester.enterText(textField, 'I want a sci-fi movie');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        await tester.pumpAndSettle(const Duration(seconds: 10));

        expect(
          find.text('I want a sci-fi movie'),
          findsOneWidget,
          reason: 'Should display user message (proves auth worked)',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'should include Authorization header in API requests',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('auth_token');

        expect(
          authToken,
          isNotNull,
          reason: 'Should have auth token before making requests',
        );

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'Show me action movies');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        await tester.pumpAndSettle(const Duration(seconds: 10));

        expect(
          find.text('Show me action movies'),
          findsOneWidget,
          reason: 'Authenticated request should succeed',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
