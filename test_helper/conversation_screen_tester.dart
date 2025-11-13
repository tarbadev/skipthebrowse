import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/message_widget.dart';

import 'base_view_tester.dart';

class ConversationScreenTester extends BaseViewTester {
  String titleKey = 'conversation_screen_title';

  ConversationScreenTester(super.tester);

  bool get isVisible => widgetExists(titleKey);

  String get title => getTextByKey(titleKey);

  Future<void> waitForIsVisible() async {
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (isVisible) {
        return;
      }
    }
    expect(find.byKey(Key(titleKey)), findsOneWidget);
  }

  List<String> getConversation() {
    final Finder messageFinders = find.byType(MessageWidget);
    final Iterable<Widget> textWidgets = messageFinders.evaluate().map(
      (element) => element.widget,
    );

    return textWidgets
        .map((Widget message) => (message as MessageWidget).text)
        .toList();
  }
}
