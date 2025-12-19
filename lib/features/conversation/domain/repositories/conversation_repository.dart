import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<Conversation> getConversation(String id);
  Future<Conversation> createConversation(String question);
  Future<Conversation> addMessage(String id, String message);

  Future<List<ConversationSummary>> listConversations({
    int limit = 20,
    int offset = 0,
  });
}
