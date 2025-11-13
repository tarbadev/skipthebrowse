import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<Conversation> getConversation(String id);
  Future<Conversation> createConversation(String question);
}
