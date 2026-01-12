import 'package:const_date_time/const_date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';
import '../../../../helpers/test_harness.dart';
import '../../../search/presentation/helpers/search_session_screen_tester.dart';
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
    registerFallbackValue(searchSession());
    registerFallbackValue(Uri());
    registerFallbackValue(
      MaterialPageRoute<void>(builder: (_) => const SizedBox()),
    );
  });

  setUp(() {
    reset(mockObserver);
    reset(mockConversationRepository);
    reset(mockSearchRepository);
  });

  testWidgets('navigates to search session screen after creating session', (
    tester,
  ) async {
    final createdSession = searchSession(interactions: [interaction()]);

    when(
      () => mockSearchRepository.createSearchSession(any()),
    ).thenAnswer((_) async => createdSession);

    await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

    final homeScreenTester = HomeScreenTester(tester);
    final searchSessionScreenTester = SearchSessionScreenTester(tester);

    expect(find.text('Looking for something to watch?'), findsOneWidget);
    expect(searchSessionScreenTester.isVisible, isFalse);

    await homeScreenTester.createSearchSession(question);

    verify(() => mockSearchRepository.createSearchSession(question)).called(1);

    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));

    expect(find.text('Looking for something to watch?'), findsNothing);
    expect(searchSessionScreenTester.isVisible, isTrue);
  });

  group('Conversation Starters', () {
    testWidgets('displays all three conversation starter chips', (
      tester,
    ) async {
      await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

      final homeScreenTester = HomeScreenTester(tester);

      expect(
        homeScreenTester.conversationStarterExists(
          "I want something thrilling to watch",
        ),
        true,
      );
      expect(
        homeScreenTester.conversationStarterExists(
          "Looking for a comedy series to binge",
        ),
        true,
      );
      expect(
        homeScreenTester.conversationStarterExists(
          "Recommend me something like Inception",
        ),
        true,
      );
    });

    testWidgets('displays helper text for conversation starters', (
      tester,
    ) async {
      await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

      expect(find.text('Start your conversation:'), findsOneWidget);
      expect(find.text('Or try a quick starter:'), findsOneWidget);
    });

    testWidgets('tapping first starter chip creates search session', (
      tester,
    ) async {
      final createdSession = searchSession(interactions: [interaction()]);

      when(
        () => mockSearchRepository.createSearchSession(any()),
      ).thenAnswer((_) async => createdSession);

      await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

      final homeScreenTester = HomeScreenTester(tester);
      final starterText = "I want something thrilling to watch";

      await homeScreenTester.tapSearchSessionStarter(starterText);

      verify(
        () => mockSearchRepository.createSearchSession(starterText),
      ).called(1);

      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));
    });

    testWidgets('tapping second starter chip creates search session', (
      tester,
    ) async {
      final createdSession = searchSession(interactions: [interaction()]);

      when(
        () => mockSearchRepository.createSearchSession(any()),
      ).thenAnswer((_) async => createdSession);

      await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

      final homeScreenTester = HomeScreenTester(tester);
      final starterText = "Looking for a comedy series to binge";

      await homeScreenTester.tapSearchSessionStarter(starterText);

      verify(
        () => mockSearchRepository.createSearchSession(starterText),
      ).called(1);

      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));
    });

    testWidgets('tapping third starter chip creates search session', (
      tester,
    ) async {
      final createdSession = searchSession(interactions: [interaction()]);

      when(
        () => mockSearchRepository.createSearchSession(any()),
      ).thenAnswer((_) async => createdSession);

      await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

      final homeScreenTester = HomeScreenTester(tester);
      final starterText = "Recommend me something like Inception";

      await homeScreenTester.tapSearchSessionStarter(starterText);

      verify(
        () => mockSearchRepository.createSearchSession(starterText),
      ).called(1);

      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));
    });

    testWidgets('custom text input still works alongside starters', (
      tester,
    ) async {
      final createdSession = searchSession(interactions: [interaction()]);

      when(
        () => mockSearchRepository.createSearchSession(any()),
      ).thenAnswer((_) async => createdSession);

      await tester.pumpRouterWidget(initialRoute: AppRoutes.home);

      final homeScreenTester = HomeScreenTester(tester);
      final customMessage = "I want to watch a documentary about nature";

      await homeScreenTester.createSearchSession(customMessage);

      verify(
        () => mockSearchRepository.createSearchSession(customMessage),
      ).called(1);

      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));
    });
  });
}
