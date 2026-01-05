import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';

import 'mocks.dart';

extension TestX on WidgetTester {
  Future<void> pumpProviderWidget(Widget widget) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await pumpWidget(
      ProviderScope(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(
            mockConversationRepository,
          ),
          pendingMessageQueueProvider.overrideWithValue(
            mockPendingMessageQueue,
          ),
          dioProvider.overrideWithValue(dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: MaterialApp(home: Scaffold(body: widget)),
      ),
    );
  }

  Future<void> pumpRouterWidget({
    String initialRoute = AppRoutes.home,
    Object? initialExtra,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    final goRouter = GoRouter(
      routes: routes,
      observers: [mockObserver],
      initialLocation: initialRoute,
      initialExtra: initialExtra,
    );

    await pumpWidget(
      ProviderScope(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(
            mockConversationRepository,
          ),
          pendingMessageQueueProvider.overrideWithValue(
            mockPendingMessageQueue,
          ),
          dioProvider.overrideWithValue(dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    );
  }
}
