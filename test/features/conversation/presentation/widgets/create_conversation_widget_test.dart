import 'package:const_date_time/const_date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/create_conversation_widget.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';
import '../../../../helpers/test_harness.dart';

void main() {
  final question = 'What movies do you recommend?';
  final response = 'Are you in a mood for ';

  setUp(() {
    reset(mockConversationRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const Conversation(
        id: 'fallback',
        messages: [],
        createdAt: ConstDateTime(2025),
      ),
    );
  });

  testWidgets('renders widget', (tester) async {
    await tester.pumpProviderWidget(
      CreateConversationWidget(callback: (_) => {}),
    );

    expect(
      find.byKey(const Key('create_conversation_text_box')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('create_conversation_button')), findsOneWidget);
  });

  testWidgets('button is enabled after entering text', (tester) async {
    await tester.pumpProviderWidget(
      CreateConversationWidget(callback: (_) => {}),
    );

    final buttonFinder = find.byKey(const Key('create_conversation_button'));

    IconButton button = tester.widget(buttonFinder);
    expect(button.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('create_conversation_text_box')),
      question,
    );
    await tester.pump();

    button = tester.widget(buttonFinder);
    expect(button.onPressed, isNotNull);
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

    await tester.enterText(
      find.byKey(const Key('create_conversation_text_box')),
      question,
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('create_conversation_button')));
    await tester.pump();
    await tester.pump();

    verify(
      () => mockConversationRepository.createConversation(question),
    ).called(1);
  });

  testWidgets('calls callback on successful creation', (tester) async {
    var callbackInvoked = false;
    final expectedConversation = conversation();

    when(
      () => mockConversationRepository.createConversation(any()),
    ).thenAnswer((_) async => expectedConversation);

    await tester.pumpProviderWidget(
      CreateConversationWidget(
        callback: (conv) {
          callbackInvoked = true;
          expect(conv, expectedConversation);
        },
      ),
    );

    await tester.enterText(
      find.byKey(const Key('create_conversation_text_box')),
      question,
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('create_conversation_button')));
    await tester.pump();
    await tester.pump();

    expect(callbackInvoked, true);
  });
}

class MockCreationSuccessCallback extends Mock {
  void call(Conversation value);
}
