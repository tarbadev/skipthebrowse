import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/core/config/router.dart';

import '../../../../../test_helper/conversation_screen_tester.dart';
import '../../../../helpers/test_factory.dart';
import '../../../../helpers/test_harness.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(conversation());
  });

  testWidgets('loads conversation at startup', (tester) async {
    final messages = [
      message(id: '1', author: 'user'),
      message(id: '2', author: 'assistant'),
    ];

    await tester.pumpRouterWidget(
      initialRoute: AppRoutes.conversation,
      initialExtra: conversation(messages: messages),
    );
    await tester.pumpAndSettle();

    final conversationPageTester = ConversationScreenTester(tester);
    expect(conversationPageTester.isVisible, isTrue);
    expect(
      conversationPageTester.title,
      equals('Conversation ID: $conversationId'),
    );
    expect(
      conversationPageTester.getConversation(),
      equals(messages.map((m) => m.content).toList()),
    );
  });
}
