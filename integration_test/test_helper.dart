import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/main.dart' as app;

class AppRobot {
  final WidgetTester tester;

  AppRobot(this.tester);

  // --- Life Cycle & State ---

  Future<void> bootApp({bool clearPreferences = true}) async {
    if (clearPreferences) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

    app.main();
    await tester.pumpAndSettle();
    await waitFor(find.byKey(const Key('home_page_title')));
  }

  // --- Home Screen Actions ---

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

  // --- Navigation Actions ---

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

  Future<void> goToAccount() async {
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
  }

  // --- Account Actions ---

  Future<void> tapCreateAccount() async {
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
  }

  // --- History Actions ---

  Future<void> searchInHistory(String query) async {
    final searchField = find.byType(TextField);
    if (searchField.evaluate().isNotEmpty) {
      await tester.enterText(searchField.first, query);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  Future<void> openHistoryItem(String term) async {
    await tester.tap(
      find
          .descendant(
            of: find.byType(ListTile),
            matching: find.textContaining(term),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  // --- Verifications ---

  void expectAtHome() {
    expect(find.byKey(const Key('home_page_title')), findsOneWidget);
  }

  void expectAtAccountSettings() {
    expect(find.text('Account'), findsOneWidget);
  }

  void expectAtUpgradeAccountScreen() {
    expect(find.text('Upgrade Account'), findsWidgets);
  }

  void expectAnonymousUserViewVisible() {
    expect(find.text('Sync Your Data'), findsOneWidget);
  }

  void expectTextVisible(String text) {
    expect(find.textContaining(text), findsWidgets);
  }

  bool isAIResponding() {
    return find.byType(SelectableText).evaluate().isNotEmpty ||
        find.byType(ElevatedButton).evaluate().isNotEmpty;
  }

  // --- Wait Helpers ---

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
    await waitFor(find.byType(ListView), timeout: const Duration(seconds: 30));
    await tester.pumpAndSettle();
  }

  Future<void> waitForHistoryItems() async {
    await waitFor(find.byType(ListTile), timeout: const Duration(seconds: 30));
  }
}

Future<void> pumpSkipTheBrowse(WidgetTester tester) async {
  final robot = AppRobot(tester);
  await robot.bootApp();
}
