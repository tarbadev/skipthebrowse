import 'package:go_router/go_router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';

import '../../features/conversation/presentation/screens/conversation_screen.dart';
import '../../features/conversation/presentation/screens/home_screen.dart';

final routes = [
  GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
  GoRoute(
    path: '/conversation',
    builder: (context, state) {
      final conversation = state.extra as Conversation;
      return ConversationScreen(conversation: conversation);
    },
  ),
];
final applicationRouter = GoRouter(routes: routes);
