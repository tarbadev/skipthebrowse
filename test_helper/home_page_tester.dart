import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class HomePageTester extends BaseViewTester {
  String textBoxKey = 'create_conversation_text_box';
  String buttonKey = 'create_conversation_button';
  String titleKey = 'home_page_title';

  HomePageTester(super.tester);

  bool get isVisible => widgetExists(textBoxKey);

  String get title => getTextByKey(titleKey);

  Future<void> createConversation(String initialMessage) async {
    expect(find.byKey(Key(textBoxKey)), findsOneWidget);
    await enterText(textBoxKey, initialMessage);
    await tester.pump();

    expect(find.byKey(Key(buttonKey)), findsOneWidget);
    await tapOnButtonByKey(buttonKey);
  }
}
