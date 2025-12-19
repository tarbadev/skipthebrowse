import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/core/config/env_config.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/main.dart';

import '../test/features/conversation/presentation/helpers/conversation_list_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/conversation_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';

void main() {
  group('Conversation Navigation E2E Tests', () {
    testWidgets('can create conversation after visiting conversation list', (
      tester,
    ) async {
      final testDio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      testDio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [dioProvider.overrideWithValue(testDio)],
          child: const SkipTheBrowse(),
        ),
      );
      await tester.pumpAndSettle();

      final homeScreenTester = HomeScreenTester(tester);
      final conversationScreenTester = ConversationScreenTester(tester);
      final conversationListTester = ConversationListScreenTester(tester);

      // Step 1: Verify we're on home screen
      expect(homeScreenTester.isVisible, true);

      // Step 2: Create first conversation
      final firstMessage = "I want to watch a comedy";
      await homeScreenTester.createConversation(firstMessage);

      // Step 3: Verify conversation screen is displayed (waitForIsVisible will handle pumping)
      await conversationScreenTester.waitForIsVisible();
      expect(conversationScreenTester.isVisible, true);
      final firstConversation = conversationScreenTester.getConversation();
      expect(firstConversation[0], firstMessage);
      expect(firstConversation[1].length, greaterThanOrEqualTo(50));

      // Step 4: Go back to home screen
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 5: Navigate to conversation list
      await homeScreenTester.tapHistoryButton();
      await conversationListTester.waitForIsVisible();
      expect(homeScreenTester.isVisible, false);
      expect(conversationListTester.isVisible, true);
      expect(conversationListTester.conversationCount, greaterThanOrEqualTo(1));

      // Tap first conversation in list
      await conversationListTester.tapConversation(0);
      await conversationScreenTester.waitForIsVisible();
      expect(conversationScreenTester.isVisible, true);

      // Back to list
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(conversationListTester.isVisible, true);

      // Step 6: Go back to home screen
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(homeScreenTester.isVisible, true);

      // Step 7: Create second conversation (this is where the bug might occur)
      final secondMessage = "Looking for a thriller";
      await homeScreenTester.createConversation(secondMessage);

      // Step 8: Verify second conversation screen is displayed (waitForIsVisible will handle pumping)
      await conversationScreenTester.waitForIsVisible();
      expect(conversationScreenTester.isVisible, true);
      final secondConversation = conversationScreenTester.getConversation();
      expect(secondConversation[0], secondMessage);
      expect(secondConversation[1].length, greaterThanOrEqualTo(50));
    });
  });
}
