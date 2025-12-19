import 'package:flutter_test/flutter_test.dart';

import 'add_message_widget_helper.dart';
import 'base_screen_tester.dart';

class HomeScreenTester extends BaseWidgetTester {
  String titleKey = 'home_page_title';
  late AddMessageWidgetHelper _addMessageWidgetHelper;

  HomeScreenTester(super.tester) {
    _addMessageWidgetHelper = AddMessageWidgetHelper(tester);
  }

  bool get isVisible => widgetExists(titleKey);

  String get title => getTextByKey(titleKey);

  Future<void> createConversation(String initialMessage) async {
    await _addMessageWidgetHelper.enterMessage(initialMessage);
    await _addMessageWidgetHelper.submit();
  }

  Future<void> tapHistoryButton() async {
    await tester.tap(find.byTooltip('View past conversations'));
    await tester.pumpAndSettle();
  }
}
