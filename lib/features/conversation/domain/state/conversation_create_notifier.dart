import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationCreateNotifier
    extends StateNotifier<AsyncValue<Conversation?>> {
  final ConversationRepository repository;

  ConversationCreateNotifier(this.repository)
    : super(const AsyncValue.data(null));

  Future<void> createConversation(String question) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => repository.createConversation(question),
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
