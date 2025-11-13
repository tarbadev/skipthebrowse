import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class BaseViewTester {
  BaseViewTester(this.tester);

  final WidgetTester tester;

  bool widgetExists(String key) {
    try {
      tester.renderObject<RenderBox>(find.byKey(Key(key)));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> tapOnButtonByKey(String key) async {
    await tester.tap(find.byKey(Key(key)));

    await tester.pumpAndSettle();
  }

  Future<void> enterText(String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
  }

  String getTextByKey(String key) {
    var textFinder = find.byKey(Key(key));
    expect(textFinder, findsOneWidget);

    Text text = tester.widget(textFinder);
    return text.data!;
  }
}
