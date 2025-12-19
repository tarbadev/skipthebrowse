import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';

import '../../features/conversation/presentation/screens/conversation_list_screen.dart';
import '../../features/conversation/presentation/screens/conversation_screen.dart';
import '../../features/conversation/presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String conversation = '/conversation';
  static const String conversationList = '/conversations';

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToConversation(
    BuildContext context,
    Conversation conversation,
  ) {
    context.push(AppRoutes.conversation, extra: conversation);
  }

  static void goToConversationList(BuildContext context) {
    context.push(conversationList);
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
      final conversation = state.extra as Conversation?;
      if (conversation == null) {
        return const HomeScreen();
      }
      return ConversationScreen(conversation: conversation);
    },
  ),
  GoRoute(
    path: AppRoutes.conversationList,
    builder: (context, state) => const ConversationListScreen(),
  ),
];
