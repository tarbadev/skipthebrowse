import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/conversation/data/models/conversation_response.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/features/conversation/presentation/screens/conversation_screen.dart';

import '../features/conversation/presentation/helpers/conversation_screen_tester.dart';
import '../helpers/test_factory.dart';
import 'helpers/mock_dio_helper.dart';

void main() {
  group('Integration Tests - Conversation Screen', () {
    testWidgets('displays conversation and adds new message', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

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
          message(
            id: '$conversationId-0',
            content: initialMessage,
            timestamp: timestamp,
            author: 'user',
          ),
          message(
            id: '$conversationId-1',
            content: initialResponse,
            timestamp: timestamp,
            author: 'assistant',
          ),
        ],
        createdAt: timestamp,
      );

      mockDioHelper.mockAddMessage(
        conversationResponse: ConversationResponse(
          id: conversationId,
          messages: [
            messageResponse(id: '1', content: initialMessage),
            messageResponse(
              id: '2',
              content: initialResponse,
              author: 'assistant',
            ),
            messageResponse(id: '3', content: userReply),
            messageResponse(
              id: '4',
              content: assistantReply,
              author: 'assistant',
            ),
          ],
          createdAt: timestamp,
        ),
        userMessage: userReply,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dioProvider.overrideWithValue(mockDioHelper.dio),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
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

    testWidgets('displays recommendation on response', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      final mockDioHelper = MockDioHelper();
      final conversationId = 'test-conversation-id';
      final initialMessage = "I'm looking for a comedy movie";
      final initialResponse = 'What style of comedy do you prefer?';
      final userReply = 'Something light and funny';
      final assistantReply =
          'Based on our conversation, here is a recommendation:';
      final timestamp = DateTime(2025, 1, 1);

      final initialConversation = Conversation(
        id: conversationId,
        messages: [
          message(
            id: '$conversationId-0',
            content: initialMessage,
            timestamp: timestamp,
            author: 'user',
          ),
          message(
            id: '$conversationId-1',
            content: initialResponse,
            timestamp: timestamp,
            author: 'assistant',
          ),
        ],
        createdAt: timestamp,
      );
      final recommendationResponse = RecommendationResponse(
        id: '1',
        title: 'Rush Hour',
        description: 'A very fun movie',
        confidence: 60,
        releaseYear: 1998,
        rating: 7,
        platforms: [
          PlatformResponse(
            name: 'Netflix',
            slug: 'netflix',
            url: 'https://example.com/netflix/rush-hour',
            isPreferred: true,
          ),
        ],
      );

      mockDioHelper.mockAddMessage(
        conversationResponse: ConversationResponse(
          id: conversationId,
          messages: [
            messageResponse(id: '1', content: initialMessage),
            messageResponse(
              id: '2',
              content: initialResponse,
              author: 'assistant',
            ),
            messageResponse(id: '3', content: userReply),
            messageResponse(
              id: '4',
              content: assistantReply,
              author: 'assistant',
              type: 'recommendation',
              recommendation: recommendationResponse,
            ),
          ],
          createdAt: timestamp,
        ),
        userMessage: userReply,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dioProvider.overrideWithValue(mockDioHelper.dio),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
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

      final recommendation = conversationScreenTester.getRecommendations().last;
      expect(recommendation['title'], recommendationResponse.title);
      expect(recommendation['description'], recommendationResponse.description);
      expect(recommendation['releaseYear'], recommendationResponse.releaseYear);
      expect(recommendation['rating'], recommendationResponse.rating);
      expect(recommendation['confidence'], recommendationResponse.confidence);
      expect(
        recommendation['platforms'],
        recommendationResponse.platforms
            .map((platform) => ({'name': platform.name, 'url': platform.url}))
            .toList(),
      );
    });
  });
}
