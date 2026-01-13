import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/main.dart' as app;

class AppRobot {
  final WidgetTester tester;

  AppRobot(this.tester);

  Future<void> bootApp({bool clearPreferences = true}) async {
    if (clearPreferences) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

    app.main();
    await tester.pumpAndSettle();
    await waitFor(find.byKey(const Key('home_page_title')));
  }

  Future<void> searchFor(String message) async {
    final textField = find.byKey(const Key('add_message_text_box'));
    final submitButton = find.byKey(const Key('add_message_button'));

    await tester.enterText(textField, message);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapQuickStarter(String prompt) async {
    final starter = find.text(prompt);
    await tester.tap(starter);
    await tester.pumpAndSettle();
  }

  Future<void> navigateBack() async {
    final backButton = find.byTooltip('Back');
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
    } else {
      await tester.tap(find.byIcon(Icons.arrow_back));
    }
    await tester.pumpAndSettle();
  }

  Future<void> goToHistory() async {
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();
  }

  Future<void> waitFor(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 500));
    }
    throw TimeoutException('Timed out waiting for finder: $finder');
  }

  Future<void> waitForAIResponse() async {
    // We wait for the "Finding the perfect match..." text to disappear
    // OR for a new message bubble to appear.
    // Let's look for the absence of the loading indicator.
    await waitFor(find.byType(ListView), timeout: const Duration(seconds: 30));
    await tester.pumpAndSettle();
  }
}

Future<void> pumpSkipTheBrowse(WidgetTester tester) async {
  final robot = AppRobot(tester);
  await robot.bootApp();
}
