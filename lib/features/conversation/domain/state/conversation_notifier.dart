import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationNotifier extends StateNotifier<AsyncValue<Conversation?>> {
  final ConversationRepository repository;

  ConversationNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> createConversation(String question) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => repository.createConversation(question),
    );
  }

  Future<void> addMessage(String id, String message) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.addMessage(id, message));
  }

  void setConversation(Conversation conversation) {
    state = AsyncValue.data(conversation);
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
