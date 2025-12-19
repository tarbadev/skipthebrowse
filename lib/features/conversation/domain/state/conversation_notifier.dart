import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationNotifier extends StateNotifier<AsyncValue<Conversation?>> {
  final ConversationRepository repository;

  ConversationNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<Conversation?> createConversation(String question) async {
    state = const AsyncLoading<Conversation?>().copyWithPrevious(state);
    try {
      final conversation = await repository.createConversation(question);
      state = AsyncValue.data(conversation);
      return conversation;
    } catch (err, stack) {
      state = AsyncError<Conversation?>(err, stack).copyWithPrevious(state);
      return null;
    }
  }

  Future<void> addMessage(String id, String message) async {
    state = const AsyncLoading<Conversation?>().copyWithPrevious(state);
    try {
      final conversation = await repository.addMessage(id, message);
      state = AsyncValue.data(conversation);
    } catch (err, stack) {
      state = AsyncError<Conversation?>(err, stack).copyWithPrevious(state);
    }
  }

  void setConversation(Conversation conversation) {
    state = AsyncValue.data(conversation);
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
