import 'package:const_date_time/const_date_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/create_conversation_widget.dart';

import '../../../../../test_helper/home_page_tester.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';
import '../../../../helpers/test_harness.dart';

void main() {
  final question = 'What movies do you recommend?';
  final response = 'Are you in a mood for ';

  setUpAll(() {
    registerFallbackValue(
      const Conversation(
        id: 'fallback',
        messages: [],
        createdAt: ConstDateTime(2025),
      ),
    );
  });

  testWidgets('calls repository on submit tap', (tester) async {
    final expectedConversation = Conversation(
      id: 'conv-123',
      messages: [
        Message(
          id: '1',
          content: question,
          timestamp: DateTime.now(),
          author: 'user',
        ),
        Message(
          id: '2',
          content: response,
          timestamp: DateTime.now(),
          author: 'assistant',
        ),
      ],
      createdAt: DateTime.now(),
    );

    when(
      () => mockConversationRepository.createConversation(any()),
    ).thenAnswer((_) async => expectedConversation);

    await tester.pumpProviderWidget(
      CreateConversationWidget(callback: (_) => {}),
    );

    final homePageTester = HomePageTester(tester);

    await homePageTester.createConversation(question);

    verify(
      () => mockConversationRepository.createConversation(question),
    ).called(1);
  });

  testWidgets('calls callback on successful creation', (tester) async {
    final mockCallback = MockCreationSuccessCallback();
    final expectedConversation = conversation();

    when(
      () => mockConversationRepository.createConversation(any()),
    ).thenAnswer((_) async => expectedConversation);

    await tester.pumpProviderWidget(
      CreateConversationWidget(callback: mockCallback.call),
    );

    final homePageTester = HomePageTester(tester);
    await homePageTester.createConversation(question);

    verify(() => mockCallback.call(expectedConversation)).called(1);
  });
}

class MockCreationSuccessCallback extends Mock {
  void call(Conversation value);
}
