import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/core/navigation/router_helper.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:skipthebrowse/features/conversation/domain/services/pending_message_queue.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';

class MockConversationRepository extends Mock
    implements ConversationRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockPendingMessageQueue extends Mock implements PendingMessageQueue {}

final mockConversationRepository = MockConversationRepository();
final mockSearchRepository = MockSearchRepository();
final mockPendingMessageQueue = MockPendingMessageQueue();

final dio = Dio(BaseOptions(baseUrl: 'http://example.com'));
final dioAdapter = DioAdapter(dio: dio);

class MockObserver extends Mock implements NavigatorObserver {}

final mockObserver = MockObserver();

class MockRouterHelper extends Mock implements RouterHelper {}

final mockRouterHelper = MockRouterHelper();
