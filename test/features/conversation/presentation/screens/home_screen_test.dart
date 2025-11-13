import 'package:const_date_time/const_date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/presentation/screens/home_screen.dart';

import '../../../../../test_helper/home_page_tester.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';
import '../../../../helpers/test_harness.dart';

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

    await tester.pumpRouterWidget(initialRoute: '/');

    expect(find.text('Looking for something to watch?'), findsOneWidget);

    final homePageTester = HomePageTester(tester);
    await homePageTester.createConversation(question);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    verify(
      () => mockConversationRepository.createConversation(question),
    ).called(1);
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));

    expect(
      find.text('Conversation ID: ${createdConversation.id}'),
      findsOneWidget,
    );
    expect(find.text('Looking for something to watch?'), findsNothing);
  });
}
