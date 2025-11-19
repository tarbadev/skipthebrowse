import 'package:const_date_time/const_date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';
import '../../../../helpers/test_harness.dart';
import '../helpers/conversation_screen_tester.dart';
import '../helpers/home_screen_tester.dart';

void main() {
  final question = 'What movies do you recommend?';

  setUpAll(() {
    registerFallbackValue(
      const Conversation(
        id: 'fallback',
        messages: [],
        createdAt: ConstDateTime(2025),
      ),
    );
    registerFallbackValue(Uri());
    registerFallbackValue(
      MaterialPageRoute<void>(builder: (_) => const SizedBox()),
    );
  });

  setUp(() {
    reset(mockObserver);
    reset(mockConversationRepository);
  });

  testWidgets('navigates to conversation screen after creating conversation', (
    tester,
  ) async {
    final createdConversation = conversation();

    when(
      () => mockConversationRepository.createConversation(any()),
    ).thenAnswer((_) async => createdConversation);
    when(
      () => mockConversationRepository.getConversation(any()),
    ).thenAnswer((_) async => createdConversation);

    await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

    final homeScreenTester = HomeScreenTester(tester);
    final conversationScreenTester = ConversationScreenTester(tester);

    expect(find.text('Looking for something to watch?'), findsOneWidget);
    expect(conversationScreenTester.isVisible, isFalse);

    await homeScreenTester.createConversation(question);

    verify(
      () => mockConversationRepository.createConversation(question),
    ).called(1);
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));

    expect(find.text('Looking for something to watch?'), findsNothing);
    expect(conversationScreenTester.isVisible, isTrue);
  });
}
