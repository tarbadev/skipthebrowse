import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_list_notifier.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_notifier.dart';

import '../../data/repositories/api_conversation_repository.dart';
import '../repositories/conversation_repository.dart';
import 'dio_provider.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final restClient = RestClient(dio, baseUrl: dio.options.baseUrl);

  return ApiConversationRepository(restClient: restClient);
});

final conversationStateProvider =
    StateNotifierProvider<ConversationNotifier, AsyncValue<Conversation?>>((
      ref,
    ) {
      return ConversationNotifier(ref.watch(conversationRepositoryProvider));
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
