import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationListNotifier
    extends StateNotifier<AsyncValue<List<ConversationSummary>>> {
  final ConversationRepository repository;

  ConversationListNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadConversations({int limit = 20, int offset = 0}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => repository.listConversations(limit: limit, offset: offset),
    );
  }

  void clear() {
    state = const AsyncValue.loading();
  }
}
