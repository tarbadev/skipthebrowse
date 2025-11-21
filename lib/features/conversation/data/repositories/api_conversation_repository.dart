import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';

import '../models/add_message_request.dart';
import '../models/create_conversation_request.dart';

class ApiConversationRepository implements ConversationRepository {
  final RestClient restClient;

  ApiConversationRepository({required this.restClient});

  @override
  Future<Conversation> createConversation(String question) async {
    final request = CreateConversationRequest(message: question, region: 'US');

    final response = await restClient.createConversation(request);

    return response.toConversation();
  }

  @override
  Future<Conversation> getConversation(String id) async {
    final response = await restClient.getConversation(id);

    return response.toConversation();
  }

  @override
  Future<Conversation> addMessage(String id, String message) async {
    final request = AddMessageRequest(message: message);

    final response = await restClient.addMessage(id, request);

    return response.toConversation();
  }
}
