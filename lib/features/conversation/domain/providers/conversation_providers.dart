import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/services/pending_message_queue.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_list_notifier.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_notifier.dart';

import '../../data/repositories/api_conversation_repository.dart';
import '../repositories/conversation_repository.dart';
import 'dio_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final pendingMessageQueueProvider = Provider<PendingMessageQueue>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PendingMessageQueue(prefs);
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final restClient = RestClient(dio, baseUrl: dio.options.baseUrl);

  return ApiConversationRepository(restClient: restClient);
});

final conversationStateProvider =
    StateNotifierProvider<ConversationNotifier, AsyncValue<Conversation?>>((
      ref,
    ) {
      return ConversationNotifier(
        ref.watch(conversationRepositoryProvider),
        ref.watch(pendingMessageQueueProvider),
      );
    });

final conversationListStateProvider =
    StateNotifierProvider.autoDispose<
      ConversationListNotifier,
      AsyncValue<List<ConversationSummary>>
    >((ref) {
      return ConversationListNotifier(
        ref.watch(conversationRepositoryProvider),
      );
    });
