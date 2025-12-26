import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_screen_tester.dart';

class ConversationListScreenTester extends BaseWidgetTester {
  ConversationListScreenTester(super.tester);

  bool get isVisible => find.text('My Conversations').evaluate().isNotEmpty;

  Future<void> waitForIsVisible() async {
    await tester.pumpAndSettle();
    expect(isVisible, true);
  }

  int get conversationCount {
    final listItems = find.byType(ListTile);
    return listItems.evaluate().length;
  }

  String getConversationPreviewText(int index) {
    final listItems = find.byType(ListTile);
    final listTile = tester.widget<ListTile>(listItems.at(index));
    final title = listTile.title as Text;
    return title.data!;
  }

  String getConversationMessageCount(int index) {
    final listItems = find.byType(ListTile);
    final listTile = tester.widget<ListTile>(listItems.at(index));
    final leading = listTile.leading as CircleAvatar;
    final text = leading.child as Text;
    return text.data!;
  }

  String getConversationTimestamp(int index) {
    final listItems = find.byType(ListTile);
    final listTile = tester.widget<ListTile>(listItems.at(index));
    final subtitle = listTile.subtitle;
    if (subtitle is Padding) {
      final text = subtitle.child as Text;
      return text.data!;
    }
    final text = subtitle as Text;
    return text.data!;
  }

  Future<void> tapConversation(int index) async {
    final listItems = find.byType(ListTile);
    await tester.tap(listItems.at(index));
    await tester.pump();
    // Wait for navigation and API call to complete
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }
}
