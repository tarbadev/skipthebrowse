import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/auth/presentation/screens/account_settings_screen.dart';
import 'package:skipthebrowse/features/auth/presentation/screens/register_login_screen.dart';

import '../../features/conversation/presentation/screens/conversation_list_screen.dart';
import '../../features/conversation/presentation/screens/conversation_screen.dart';
import '../../features/conversation/presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String conversation = '/conversation';
  static const String conversationList = '/conversations';
  static const String accountSettings = '/account';
  static const String registerLogin = '/auth/register-login';

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

  static void goToAccountSettings(BuildContext context) {
    context.push(accountSettings);
  }

  static void goToRegisterLogin(
    BuildContext context, {
    bool isRegister = true,
    bool isMerge = false,
  }) {
    context.push(
      registerLogin,
      extra: {'isRegister': isRegister, 'isMerge': isMerge},
    );
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
  GoRoute(
    path: AppRoutes.accountSettings,
    builder: (context, state) => const AccountSettingsScreen(),
  ),
  GoRoute(
    path: AppRoutes.registerLogin,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      final isRegister = extra?['isRegister'] as bool? ?? true;
      final isMerge = extra?['isMerge'] as bool? ?? false;
      return RegisterLoginScreen(isRegister: isRegister, isMerge: isMerge);
    },
  ),
];
