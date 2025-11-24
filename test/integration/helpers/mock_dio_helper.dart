import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class MockDioHelper {
  final Dio dio;
  final DioAdapter dioAdapter;

  MockDioHelper({String baseUrl = 'http://localhost:8000'})
    : dio = Dio(BaseOptions(baseUrl: baseUrl)),
      dioAdapter = DioAdapter(
        dio: Dio(BaseOptions(baseUrl: baseUrl)),
        matcher: const FullHttpRequestMatcher(),
      ) {
    dio.httpClientAdapter = dioAdapter;
  }

  void mockCreateConversation({
    required String conversationId,
    required String userMessage,
    required String assistantResponse,
    required DateTime timestamp,
  }) {
    dioAdapter.onPost(
      '/api/v1/conversations',
      (server) => server.reply(201, {
        'id': conversationId,
        'messages': [
          {
            'id': '$conversationId-0',
            'content': userMessage,
            'timestamp': timestamp.toIso8601String(),
            'author': 'user',
            'type': 'question',
          },
          {
            'id': '$conversationId-1',
            'content': assistantResponse,
            'timestamp': timestamp.toIso8601String(),
            'author': 'assistant',
            'type': 'question',
          },
        ],
        'created_at': timestamp.toIso8601String(),
      }),
      data: {'message': userMessage, 'region': 'US'},
    );
  }

  void mockGetConversation({
    required String conversationId,
    required List<Map<String, String>> messages,
    required DateTime timestamp,
  }) {
    final messagesJson = messages
        .asMap()
        .entries
        .map(
          (entry) => {
            'id': '$conversationId-${entry.key}',
            'content': entry.value['content']!,
            'timestamp': timestamp.toIso8601String(),
            'author': entry.value['author']!,
            'type': 'question',
          },
        )
        .toList();

    dioAdapter.onGet(
      '/api/v1/conversations/$conversationId',
      (server) => server.reply(200, {
        'id': conversationId,
        'messages': messagesJson,
        'created_at': timestamp.toIso8601String(),
      }),
    );
  }

  void mockAddMessage({
    required String conversationId,
    required List<Map<String, String>> allMessages,
    required String userMessage,
    required DateTime timestamp,
  }) {
    final messagesJson = allMessages
        .asMap()
        .entries
        .map(
          (entry) => {
            'id': '$conversationId-${entry.key}',
            'content': entry.value['content']!,
            'timestamp': timestamp.toIso8601String(),
            'author': entry.value['author']!,
            'type': 'question',
          },
        )
        .toList();

    dioAdapter.onPost(
      '/api/v1/conversations/$conversationId/respond',
      (server) => server.reply(200, {
        'id': conversationId,
        'messages': messagesJson,
        'created_at': timestamp.toIso8601String(),
      }),
      data: {'message': userMessage},
    );
  }
}
