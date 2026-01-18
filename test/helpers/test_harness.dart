import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/auth/domain/providers/auth_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/features/search/domain/providers/search_providers.dart';

import 'mocks.dart';

extension TestX on WidgetTester {
  Future<void> pumpProviderWidget(Widget widget) async {
    // Set a consistent surface size for responsive testing (1280x1000)
    await binding.setSurfaceSize(const Size(1280, 1000));

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    FlutterSecureStorage.setMockInitialValues({});

    await pumpWidget(
      ProviderScope(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(
            mockConversationRepository,
          ),
          searchRepositoryProvider.overrideWithValue(mockSearchRepository),
          pendingMessageQueueProvider.overrideWithValue(
            mockPendingMessageQueue,
          ),
          dioProvider.overrideWithValue(dio),
          baseDioProvider.overrideWithValue(dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          secureStorageProvider.overrideWithValue(const FlutterSecureStorage()),
        ],
        child: MaterialApp(home: Scaffold(body: widget)),
      ),
    );
  }

  Future<void> pumpRouterWidget({
    String initialRoute = AppRoutes.home,
    Object? initialExtra,
  }) async {
    // Set a consistent surface size for responsive testing (1280x1000)
    await binding.setSurfaceSize(const Size(1280, 1000));

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    FlutterSecureStorage.setMockInitialValues({});

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
          searchRepositoryProvider.overrideWithValue(mockSearchRepository),
          pendingMessageQueueProvider.overrideWithValue(
            mockPendingMessageQueue,
          ),
          dioProvider.overrideWithValue(dio),
          baseDioProvider.overrideWithValue(dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          secureStorageProvider.overrideWithValue(const FlutterSecureStorage()),
        ],
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    );
  }

  /// Helper to reset the surface size if needed
  Future<void> resetSurfaceSize() async {
    await binding.setSurfaceSize(null);
  }
}
