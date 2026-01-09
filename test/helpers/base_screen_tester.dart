import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class BaseWidgetTester {
  BaseWidgetTester(this.tester);

  final WidgetTester tester;

  bool widgetExists(String key) {
    try {
      tester.renderObject<RenderBox>(find.byKey(Key(key)));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> tapOnWidgetByKey(String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder, warnIfMissed: false);

    await tester.pump();
  }

  Future<void> enterText(String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
  }

  String getTextByKey(String key) {
    var textFinder = find.byKey(Key(key), skipOffstage: false);
    expect(textFinder, findsOneWidget);

    Text text = tester.widget(textFinder);
    return text.data!;
  }
}
