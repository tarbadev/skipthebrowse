import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/pending_message.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:skipthebrowse/features/conversation/domain/services/pending_message_queue.dart';

class ConversationNotifier extends StateNotifier<AsyncValue<Conversation?>> {
  final ConversationRepository repository;
  final PendingMessageQueue pendingQueue;

  ConversationNotifier(this.repository, this.pendingQueue)
    : super(const AsyncValue.data(null));

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

  Future<void> addMessage(String id, String messageContent) async {
    final currentConversation = state.value;
    if (currentConversation == null) return;

    final pendingMessage = PendingMessage(
      conversationId: id,
      content: messageContent,
      timestamp: DateTime.now(),
    );

    await pendingQueue.enqueue(pendingMessage);

    final userMessage = Message(
      id: 'temp_${pendingMessage.timestamp.millisecondsSinceEpoch}',
      content: messageContent,
      timestamp: pendingMessage.timestamp,
      author: 'user',
      type: MessageType.question,
      status: MessageStatus.pending,
    );

    final updatedConversation = Conversation(
      id: currentConversation.id,
      messages: [...currentConversation.messages, userMessage],
      createdAt: currentConversation.createdAt,
    );

    state = AsyncValue.data(updatedConversation);

    try {
      final conversation = await repository.addMessage(id, messageContent);
      await pendingQueue.remove(pendingMessage);
      state = AsyncValue.data(conversation);
    } catch (err) {
      final failedMessage = userMessage.copyWith(status: MessageStatus.failed);
      final failedConversation = Conversation(
        id: currentConversation.id,
        messages: [...currentConversation.messages, failedMessage],
        createdAt: currentConversation.createdAt,
      );
      state = AsyncValue.data(failedConversation);
    }
  }

  Future<void> retryPendingMessages(String conversationId) async {
    final pendingMessages = await pendingQueue.getForConversation(
      conversationId,
    );

    for (final pendingMessage in pendingMessages) {
      if (pendingMessage.retryCount >= 3) {
        continue;
      }

      try {
        await repository.addMessage(
          pendingMessage.conversationId,
          pendingMessage.content,
        );
        await pendingQueue.remove(pendingMessage);
      } catch (err) {
        await pendingQueue.updateRetryCount(
          pendingMessage,
          pendingMessage.retryCount + 1,
        );
      }
    }

    final currentConversation = state.value;
    if (currentConversation == null) return;

    try {
      final conversation = await repository.getConversation(conversationId);
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
