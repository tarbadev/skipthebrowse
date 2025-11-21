import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/core/config/router.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';
import '../../../../helpers/test_harness.dart';
import '../helpers/conversation_screen_tester.dart';

void main() {
  final messages = [
    message(id: '1', author: 'user'),
    message(id: '2', author: 'assistant'),
  ];

  setUpAll(() {
    registerFallbackValue(conversation());
  });

  testWidgets('loads conversation at startup', (tester) async {
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

  testWidgets('adds new message and calls API', (tester) async {
    final newMessage = 'I want to see something funny';
    final updatedMessages = [
      ...messages,
      message(id: '3', content: newMessage),
    ];
    final updatedConversation = conversation(messages: updatedMessages);
    when(
      () => mockConversationRepository.addMessage(any(), any()),
    ).thenAnswer((_) async => updatedConversation);

    await tester.pumpRouterWidget(
      initialRoute: AppRoutes.conversation,
      initialExtra: conversation(messages: messages),
    );
    await tester.pumpAndSettle();

    final conversationPageTester = ConversationScreenTester(tester);
    expect(conversationPageTester.isVisible, isTrue);

    await tester.pumpAndSettle();
    // await tester.pump(Duration(milliseconds: 1000));
    await conversationPageTester.addMessage(newMessage);

    expect(
      conversationPageTester.getConversation(),
      equals(updatedMessages.map((m) => m.content).toList()),
    );

    verify(
      () => mockConversationRepository.addMessage(conversationId, newMessage),
    ).called(1);
  });
}
