import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';

import 'mocks.dart';

extension TestX on WidgetTester {
  Future<void> pumpProviderWidget(Widget widget) async => await pumpWidget(
    ProviderScope(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(
          mockConversationRepository,
        ),
        dioProvider.overrideWithValue(dio),
      ],
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );

  Future<void> pumpRouterWidget({
    String initialRoute = AppRoutes.home,
    Object? initialExtra,
  }) async {
    final goRouter = GoRouter(
      routes: applicationRouter.configuration.routes,
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
          dioProvider.overrideWithValue(dio),
        ],
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    );
  }
}
