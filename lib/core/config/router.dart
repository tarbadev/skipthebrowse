import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';

import '../../features/conversation/presentation/screens/conversation_screen.dart';
import '../../features/conversation/presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String conversation = '/conversation';

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToConversation(
    BuildContext context,
    Conversation conversation,
  ) {
    context.push(AppRoutes.conversation, extra: conversation);
  }
}

final routes = [
  GoRoute(
    path: AppRoutes.home,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: AppRoutes.conversation,
    builder: (context, state) {
      final conversation = state.extra as Conversation;
      return ConversationScreen(conversation: conversation);
    },
  ),
];
final applicationRouter = GoRouter(routes: routes);
