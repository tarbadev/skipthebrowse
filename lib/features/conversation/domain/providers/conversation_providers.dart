import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import '../../data/repositories/api_conversation_repository.dart';
import '../repositories/conversation_repository.dart';
import 'dio_provider.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final restClient = RestClient(dio);

  return ApiConversationRepository(restClient: restClient);
});
