import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/base_screen_tester.dart';

class SearchSessionListScreenTester extends BaseWidgetTester {
  SearchSessionListScreenTester(super.tester);

  bool get isVisible => find.text('My Searches').evaluate().isNotEmpty;

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

  String? getMatchedContent(int index) {
    // For search sessions, the preview text is in the title
    return getConversationPreviewText(index);
  }

  String getConversationMessageCount(int index) {
    final listItems = find.byType(ListTile);
    final listTile = tester.widget<ListTile>(listItems.at(index));
    final leading = listTile.leading;

    if (leading is Stack) {
      final circleAvatar = leading.children.first as CircleAvatar;
      final text = circleAvatar.child as Text;
      return text.data!;
    } else if (leading is CircleAvatar) {
      final text = leading.child as Text;
      return text.data!;
    }

    throw Exception('Unexpected leading widget type: ${leading.runtimeType}');
  }

  int getInteractionCount(int index) {
    final count = getConversationMessageCount(index);
    return int.parse(count);
  }

  int getRecommendationCount(int index) {
    final listItems = find.byType(ListTile);
    final listTile = tester.widget<ListTile>(listItems.at(index));
    final leading = listTile.leading;

    if (leading is Stack && leading.children.length > 1) {
      // There's a recommendation badge
      final badge = leading.children[1] as Positioned;
      final container = badge.child as Container;
      final text = container.child as Text;
      return int.parse(text.data!);
    }

    return 0;
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

  bool get hasSearchBar => find.byType(TextField).evaluate().isNotEmpty;

  Future<void> enterSearchQuery(String query) async {
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, query);
    await tester.pump();
    // Wait for search to complete
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }

  Future<void> clearSearch() async {
    final clearButton = find.byIcon(Icons.clear_rounded);
    if (clearButton.evaluate().isNotEmpty) {
      await tester.tap(clearButton);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 10));
    }
  }

  bool get hasNoResultsMessage =>
      find.text('No results found').evaluate().isNotEmpty;

  bool get hasEmptyStateMessage =>
      find.text('No search sessions yet').evaluate().isNotEmpty;
}
