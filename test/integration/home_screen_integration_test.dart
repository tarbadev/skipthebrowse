import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/main.dart';

import '../features/conversation/presentation/helpers/conversation_screen_tester.dart';
import '../features/conversation/presentation/helpers/home_screen_tester.dart';
import 'helpers/mock_dio_helper.dart';

void main() {
  group('Home Screen Integration Tests (Mocked)', () {
    testWidgets('creates a conversation and navigates to conversation screen', (
      tester,
    ) async {
      final mockDioHelper = MockDioHelper();
      final initialMessage = "I'm looking for a movie to watch";
      final assistantResponse = 'What genre are you interested in?';
      final conversationId = 'test-conversation-id';
      final timestamp = DateTime(2025, 1, 1);

      mockDioHelper.mockCreateConversation(
        conversationId: conversationId,
        userMessage: initialMessage,
        assistantResponse: assistantResponse,
        timestamp: timestamp,
      );

      mockDioHelper.mockGetConversation(
        conversationId: conversationId,
        messages: [
          {'content': initialMessage, 'author': 'user'},
          {'content': assistantResponse, 'author': 'assistant'},
        ],
        timestamp: timestamp,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [dioProvider.overrideWithValue(mockDioHelper.dio)],
          child: const SkipTheBrowse(),
        ),
      );
      await tester.pumpAndSettle();

      final homeScreenTester = HomeScreenTester(tester);
      expect(homeScreenTester.isVisible, true);
      expect(homeScreenTester.title, 'Looking for something to watch?');

      await homeScreenTester.createConversation(initialMessage);
      await tester.pumpAndSettle();

      final conversationScreenTester = ConversationScreenTester(tester);
      await conversationScreenTester.waitForIsVisible();
      expect(conversationScreenTester.isVisible, true);

      final conversation = conversationScreenTester.getConversation();
      expect(conversation[0], initialMessage);
      expect(conversation[1], assistantResponse);
    });
  });
}
