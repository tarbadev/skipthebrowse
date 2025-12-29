import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/search_result.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationListState extends Equatable {
  final List<ConversationSummary>? conversations;
  final ConversationSearchResults? searchResults;
  final bool isSearchMode;

  const ConversationListState({
    this.conversations,
    this.searchResults,
    required this.isSearchMode,
  });

  factory ConversationListState.normal(
    List<ConversationSummary> conversations,
  ) {
    return ConversationListState(
      conversations: conversations,
      searchResults: null,
      isSearchMode: false,
    );
  }

  factory ConversationListState.search(ConversationSearchResults results) {
    return ConversationListState(
      conversations: null,
      searchResults: results,
      isSearchMode: true,
    );
  }

  @override
  List<Object?> get props => [conversations, searchResults, isSearchMode];
}

class ConversationListNotifier
    extends StateNotifier<AsyncValue<ConversationListState>> {
  final ConversationRepository repository;

  ConversationListNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadConversations({int limit = 20, int offset = 0}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final conversations = await repository.listConversations(
        limit: limit,
        offset: offset,
      );
      return ConversationListState.normal(conversations);
    });
  }

  Future<void> searchConversations(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (query.isEmpty) {
      return loadConversations(limit: limit, offset: offset);
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final results = await repository.searchConversations(
        query: query,
        limit: limit,
        offset: offset,
      );
      return ConversationListState.search(results);
    });
  }

  void clear() {
    state = const AsyncValue.loading();
  }
}
