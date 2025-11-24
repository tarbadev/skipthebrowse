import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/features/conversation/presentation/screens/conversation_screen.dart';

import '../features/conversation/presentation/helpers/conversation_screen_tester.dart';
import 'helpers/mock_dio_helper.dart';

void main() {
  group('Integration Tests - Conversation Screen', () {
    testWidgets('displays conversation and adds new message', (tester) async {
      final mockDioHelper = MockDioHelper();
      final conversationId = 'test-conversation-id';
      final initialMessage = "I'm looking for a comedy movie";
      final initialResponse = 'What style of comedy do you prefer?';
      final userReply = 'Something light and funny';
      final assistantReply = 'How about a romantic comedy or slapstick?';
      final timestamp = DateTime(2025, 1, 1);

      final initialConversation = Conversation(
        id: conversationId,
        messages: [
          Message(
            id: '$conversationId-0',
            content: initialMessage,
            timestamp: timestamp,
            author: 'user',
          ),
          Message(
            id: '$conversationId-1',
            content: initialResponse,
            timestamp: timestamp,
            author: 'assistant',
          ),
        ],
        createdAt: timestamp,
      );

      mockDioHelper.mockAddMessage(
        conversationId: conversationId,
        allMessages: [
          {'content': initialMessage, 'author': 'user'},
          {'content': initialResponse, 'author': 'assistant'},
          {'content': userReply, 'author': 'user'},
          {'content': assistantReply, 'author': 'assistant'},
        ],
        userMessage: userReply,
        timestamp: timestamp,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [dioProvider.overrideWithValue(mockDioHelper.dio)],
          child: MaterialApp(
            home: ConversationScreen(conversation: initialConversation),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final conversationScreenTester = ConversationScreenTester(tester);
      await conversationScreenTester.waitForIsVisible();
      expect(conversationScreenTester.isVisible, true);

      var conversation = conversationScreenTester.getConversation();
      expect(conversation.length, 2);
      expect(conversation[0], initialMessage);
      expect(conversation[1], initialResponse);

      await conversationScreenTester.addMessage(userReply);
      await tester.pumpAndSettle();

      conversation = conversationScreenTester.getConversation();
      expect(conversation.length, 4);
      expect(conversation[2], userReply);
      expect(conversation[3], assistantReply);
    });
  });
}
