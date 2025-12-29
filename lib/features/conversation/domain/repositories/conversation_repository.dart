import '../entities/conversation.dart';
import '../entities/search_result.dart';

abstract class ConversationRepository {
  Future<Conversation> getConversation(String id);
  Future<Conversation> createConversation(String question);
  Future<Conversation> addMessage(String id, String message);

  Future<List<ConversationSummary>> listConversations({
    int limit = 20,
    int offset = 0,
  });

  Future<ConversationSearchResults> searchConversations({
    required String query,
    int limit = 20,
    int offset = 0,
  });
}
