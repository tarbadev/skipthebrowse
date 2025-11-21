import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/api_conversation_repository.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';

import '../../../../helpers/test_factory.dart';

void main() {
  late ApiConversationRepository subject;
  late Dio dio;
  late DioAdapter dioAdapter;

  const baseUrl = 'https://example.com';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());

    subject = ApiConversationRepository(restClient: RestClient(dio));
  });

  test('createConversation calls the API', () async {
    final messageContent = 'I want to watch a recent movie';
    final response = 'How recent, last year? Last 6 months? Last month?';

    final expectedConversation = Conversation(
      id: conversationId,
      messages: [
        Message(
          id: '1',
          content: messageContent,
          timestamp: DateTime(2025),
          author: 'user',
        ),
        Message(
          id: '2',
          content: response,
          timestamp: DateTime(2025),
          author: 'assistant',
        ),
      ],
      createdAt: DateTime(2025),
    );

    dioAdapter.onPost(
      '/api/v1/conversations',
      (server) => server.reply(201, {
        'id': conversationId,
        'messages': [
          {
            'id': '1',
            'content': messageContent,
            'timestamp': DateTime(2025).toIso8601String(),
            'author': 'user',
            'type': 'question',
          },
          {
            'id': '2',
            'content': response,
            'timestamp': DateTime(2025).toIso8601String(),
            'author': 'assistant',
            'type': 'question',
          },
        ],
        'created_at': DateTime(2025).toIso8601String(),
      }),
      data: {'message': messageContent, 'region': 'US'},
    );

    final actual = await subject.createConversation(messageContent);

    expect(actual, equals(expectedConversation));
  });

  test('addMessage calls the API', () async {
    final messageContent = 'I want to watch a recent movie';
    final response = 'How recent, last year? Last 6 months? Last month?';

    final expectedConversation = Conversation(
      id: conversationId,
      messages: [
        Message(
          id: '1',
          content: messageContent,
          timestamp: DateTime(2025),
          author: 'user',
        ),
        Message(
          id: '2',
          content: response,
          timestamp: DateTime(2025),
          author: 'assistant',
        ),
      ],
      createdAt: DateTime(2025),
    );

    dioAdapter.onPost(
      '/api/v1/conversations/$conversationId/respond',
      (server) => server.reply(200, {
        'id': conversationId,
        'messages': [
          {
            'id': '1',
            'content': messageContent,
            'timestamp': DateTime(2025).toIso8601String(),
            'author': 'user',
            'type': 'question',
          },
          {
            'id': '2',
            'content': response,
            'timestamp': DateTime(2025).toIso8601String(),
            'author': 'assistant',
            'type': 'question',
          },
        ],
        'created_at': DateTime(2025).toIso8601String(),
      }),
      data: {'message': messageContent},
    );

    final actual = await subject.addMessage(conversationId, messageContent);

    expect(actual, equals(expectedConversation));
  });

  test('getConversation calls the API', () async {
    final messageUser = 'I want to watch a recent movie';
    final messageAssistant =
        'How recent, last year? Last 6 months? Last month?';

    final expectedConversation = Conversation(
      id: conversationId,
      messages: [
        Message(
          id: '1',
          content: messageUser,
          timestamp: DateTime(2025),
          author: 'user',
        ),
        Message(
          id: '2',
          content: messageAssistant,
          timestamp: DateTime(2025),
          author: 'assistant',
        ),
      ],
      createdAt: DateTime(2025),
    );

    dioAdapter.onGet(
      '/api/v1/conversations/$conversationId',
      (server) => server.reply(200, {
        'id': conversationId,
        'messages': [
          {
            'id': '1',
            'content': messageUser,
            'timestamp': DateTime(2025).toIso8601String(),
            'author': 'user',
            'type': 'question',
          },
          {
            'id': '2',
            'content': messageAssistant,
            'timestamp': DateTime(2025).toIso8601String(),
            'author': 'assistant',
            'type': 'question',
          },
        ],
        'created_at': DateTime(2025).toIso8601String(),
      }),
    );

    final actual = await subject.getConversation(conversationId);

    expect(actual, equals(expectedConversation));
  });
}
