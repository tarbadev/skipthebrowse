import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/core/config/env_config.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/main.dart';

import '../test/features/conversation/presentation/helpers/conversation_screen_tester.dart';
import '../test/features/conversation/presentation/helpers/home_screen_tester.dart';

void main() {
  group('Home Tests', () {
    testWidgets('create a conversation', (tester) async {
      final initialMessage =
          "I'm looking for a movie to watch with my best friend";

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
      expect(homeScreenTester.isVisible, true);
      expect(homeScreenTester.title, 'Looking for something to watch?');

      await homeScreenTester.createConversation(initialMessage);
      await tester.pumpAndSettle();

      final conversationPageTester = ConversationScreenTester(tester);

      await conversationPageTester.waitForIsVisible();
      expect(conversationPageTester.isVisible, true);

      var conversation = conversationPageTester.getConversation();

      expect(conversation[0], initialMessage);
      expect(conversation[1].length, greaterThanOrEqualTo(50));

      final response = 'I want to watch a comedy';
      await conversationPageTester.addMessage(response);
      await tester.pumpAndSettle();

      conversation = conversationPageTester.getConversation();
      expect(conversation[2], response);
      expect(conversation[3].length, greaterThanOrEqualTo(50));
    });
  });
}
