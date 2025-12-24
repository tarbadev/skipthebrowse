import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/pending_message.dart';

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
    registerFallbackValue(
      PendingMessage(
        conversationId: 'test',
        content: 'test',
        timestamp: DateTime.now(),
      ),
    );
  });

  setUp(() {
    reset(mockConversationRepository);
    reset(mockPendingMessageQueue);

    when(
      () => mockPendingMessageQueue.enqueue(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockPendingMessageQueue.remove(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockPendingMessageQueue.getForConversation(any()),
    ).thenAnswer((_) async => []);
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
    await conversationPageTester.addMessage(newMessage);

    expect(
      conversationPageTester.getConversation(),
      equals(updatedMessages.map((m) => m.content).toList()),
    );

    verify(
      () => mockConversationRepository.addMessage(conversationId, newMessage),
    ).called(1);
  });

  testWidgets('displays recommendation on after response', (tester) async {
    final newMessage = 'I have a recommendation for you';
    var expectedRecommendation = recommendation();
    final updatedMessages = [
      ...messages,
      message(
        id: '3',
        content: newMessage,
        type: MessageType.recommendation,
        recommendation: expectedRecommendation,
      ),
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
    await conversationPageTester.addMessage(newMessage);

    expect(
      conversationPageTester.getConversation(),
      equals(updatedMessages.map((m) => m.content).toList()),
    );

    expect(
      conversationPageTester.getRecommendations().last,
      equals({
        'title': expectedRecommendation.title,
        'description': expectedRecommendation.description,
        'releaseYear': expectedRecommendation.releaseYear,
        'rating': expectedRecommendation.rating,
        'confidence': expectedRecommendation.confidence,
        'platforms': expectedRecommendation.platforms.map(
          (p) => {'name': p.name, 'url': p.url},
        ),
      }),
    );

    verify(
      () => mockConversationRepository.addMessage(conversationId, newMessage),
    ).called(1);
  });
}
