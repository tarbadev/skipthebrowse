import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:skipthebrowse/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:skipthebrowse/features/auth/data/storage/auth_storage.dart';
import 'package:skipthebrowse/features/conversation/data/models/conversation_response.dart';

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

    // Add AuthInterceptor to the mock dio instance so headers are handled
    const storage = FlutterSecureStorage();
    FlutterSecureStorage.setMockInitialValues({});
    dio.interceptors.add(AuthInterceptor(SecureAuthStorage(storage)));
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
    required ConversationResponse conversationResponse,
    required String userMessage,
  }) => dioAdapter.onPost(
    '/api/v1/conversations/${conversationResponse.id}/respond',
    (server) => server.reply(200, conversationResponse.toJson()),
    data: {'message': userMessage},
  );

  void mockListConversations({
    required List<Map<String, dynamic>> conversations,
    int total = 0,
    int limit = 20,
    int offset = 0,
  }) {
    dioAdapter.onGet(
      '/api/v1/conversations',
      (server) => server.reply(200, {
        'conversations': conversations,
        'total': total,
        'limit': limit,
        'offset': offset,
      }),
      queryParameters: {'limit': limit, 'offset': offset},
    );
  }

  void mockCreateAnonymousUser({
    required String userId,
    required String username,
    required String accessToken,
  }) {
    dioAdapter.onPost(
      '/api/v1/auth/anonymous',
      (server) => server.reply(201, {
        'access_token': accessToken,
        'token_type': 'bearer',
        'user': {
          'id': userId,
          'username': username,
          'email': null,
          'is_anonymous': true,
        },
      }),
      data: {'username': username},
    );
  }

  void mockRegisterUser({
    required String userId,
    required String username,
    required String email,
    required String password,
    required String accessToken,
  }) {
    dioAdapter.onPost(
      '/api/v1/auth/register',
      (server) => server.reply(201, {
        'access_token': accessToken,
        'token_type': 'bearer',
        'user': {
          'id': userId,
          'username': username,
          'email': email,
          'is_anonymous': false,
        },
      }),
      data: {'email': email, 'password': password, 'username': username},
    );
  }

  void mockLoginUser({
    required String userId,
    required String username,
    required String email,
    required String password,
    required String accessToken,
  }) {
    dioAdapter.onPost(
      '/api/v1/auth/login',
      (server) => server.reply(200, {
        'access_token': accessToken,
        'token_type': 'bearer',
        'user': {
          'id': userId,
          'username': username,
          'email': email,
          'is_anonymous': false,
        },
      }),
      data: {'email': email, 'password': password},
    );
  }

  void mockMergeAnonymousAccount({
    required String userId,
    required String username,
    required String email,
    required String password,
    required String accessToken,
  }) {
    dioAdapter.onPost(
      '/api/v1/auth/merge',
      (server) => server.reply(200, {
        'access_token': accessToken,
        'token_type': 'bearer',
        'user': {
          'id': userId,
          'username': username,
          'email': email,
          'is_anonymous': false,
        },
      }),
      data: {'email': email, 'password': password},
    );
  }

  void mockCreateSearchSession({
    required String sessionId,
    required String initialMessage,
    required List<Map<String, dynamic>> interactions,
    required DateTime timestamp,
  }) {
    dioAdapter.onPost(
      '/api/v1/search-sessions',
      (server) => server.reply(201, {
        'id': sessionId,
        'initial_message': initialMessage,
        'interactions': interactions,
        'recommendations': [],
        'created_at': timestamp.toIso8601String(),
      }),
      data: {'message': initialMessage, 'region': 'US'},
    );
  }

  void mockGetSearchSession({
    required String sessionId,
    required String? initialMessage,
    required List<Map<String, dynamic>> interactions,
    required DateTime timestamp,
  }) {
    dioAdapter.onGet(
      '/api/v1/search-sessions/$sessionId',
      (server) => server.reply(200, {
        'id': sessionId,
        'initial_message': initialMessage,
        'interactions': interactions,
        'recommendations': [],
        'created_at': timestamp.toIso8601String(),
      }),
    );
  }

  void mockListSearchSessions({
    required List<Map<String, dynamic>> sessions,
    int total = 0,
    int limit = 50,
    int offset = 0,
  }) {
    dioAdapter.onGet(
      '/api/v1/search-sessions',
      (server) => server.reply(200, {'sessions': sessions, 'total': total}),
      queryParameters: {'limit': limit, 'offset': offset},
    );
  }
}
