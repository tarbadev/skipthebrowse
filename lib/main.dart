import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'core/config/env_config.dart';
import 'core/providers/route_provider.dart';
import 'features/auth/data/repositories/api_auth_repository.dart';
import 'features/auth/domain/services/auth_initializer.dart';
import 'features/conversation/data/repositories/rest_client.dart';
import 'features/conversation/domain/providers/conversation_providers.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize authentication (create anonymous user if needed)
  final dio = Dio(BaseOptions(baseUrl: EnvConfig.apiBaseUrl));
  final restClient = RestClient(dio);
  final authRepository = ApiAuthRepository(restClient, sharedPreferences);
  final authInitializer = AuthInitializer(authRepository);
  await authInitializer.initialize();
  final bool isDesktopApp =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  if (isDesktopApp) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://cacb736d46c7c03dbc9ee7ac6db6bb39@o379974.ingest.us.sentry.io/4510638315929600';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
      options.environment = EnvConfig.environment;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const SkipTheBrowse(),
        ),
      ),
    ),
  );
}

class SkipTheBrowse extends ConsumerWidget {
  const SkipTheBrowse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SkipTheBrowse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF181818),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          surface: const Color(0xFF181818),
        ),
      ),
      routerConfig: router,
    );
  }
}
