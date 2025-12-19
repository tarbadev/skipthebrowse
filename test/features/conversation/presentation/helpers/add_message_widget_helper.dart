import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_screen_tester.dart';

class AddMessageWidgetHelper extends BaseWidgetTester {
  String textBoxKey = 'add_message_text_box';
  String buttonKey = 'add_message_button';

  AddMessageWidgetHelper(super.tester);

  void isVisible() {
    expect(find.byKey(Key(textBoxKey)), findsOneWidget);
    expect(find.byKey(Key(buttonKey)), findsOneWidget);
  }

  IconButton getButton() {
    final buttonFinder = find.byKey(Key(buttonKey));

    return tester.widget(buttonFinder);
  }

  Future<void> enterMessage(String message) async {
    await tapOnWidgetByKey(textBoxKey);
    expect(find.byKey(Key(textBoxKey)), findsOneWidget);
    await enterText(textBoxKey, message);
    await tester.pump();
  }

  Future<void> submit() async {
    expect(find.byKey(Key(buttonKey)), findsOneWidget);
    await tapOnWidgetByKey(buttonKey);
  }
}
