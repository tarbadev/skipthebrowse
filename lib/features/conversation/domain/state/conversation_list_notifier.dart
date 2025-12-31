import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/search_result.dart';
import 'package:skipthebrowse/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationListState extends Equatable {
  final List<ConversationSummary>? conversations;
  final ConversationSearchResults? searchResults;
  final bool isSearchMode;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentOffset;

  const ConversationListState({
    this.conversations,
    this.searchResults,
    required this.isSearchMode,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentOffset = 0,
  });

  factory ConversationListState.normal(
    List<ConversationSummary> conversations, {
    bool hasMore = true,
    int offset = 0,
  }) {
    return ConversationListState(
      conversations: conversations,
      searchResults: null,
      isSearchMode: false,
      hasMore: hasMore,
      currentOffset: offset,
    );
  }

  factory ConversationListState.search(
    ConversationSearchResults results, {
    bool hasMore = true,
    int offset = 0,
  }) {
    return ConversationListState(
      conversations: null,
      searchResults: results,
      isSearchMode: true,
      hasMore: hasMore,
      currentOffset: offset,
    );
  }

  ConversationListState copyWith({
    List<ConversationSummary>? conversations,
    ConversationSearchResults? searchResults,
    bool? isSearchMode,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentOffset,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      searchResults: searchResults ?? this.searchResults,
      isSearchMode: isSearchMode ?? this.isSearchMode,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    searchResults,
    isSearchMode,
    hasMore,
    isLoadingMore,
    currentOffset,
  ];
}

class ConversationListNotifier
    extends StateNotifier<AsyncValue<ConversationListState>> {
  final ConversationRepository repository;
  static const int _pageSize = 20;

  ConversationListNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadConversations({int limit = 20, int offset = 0}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final conversations = await repository.listConversations(
        limit: limit,
        offset: offset,
      );
      final hasMore = conversations.length >= limit;
      return ConversationListState.normal(
        conversations,
        hasMore: hasMore,
        offset: offset + conversations.length,
      );
    });
  }

  Future<void> loadMoreConversations() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isSearchMode ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final moreConversations = await repository.listConversations(
        limit: _pageSize,
        offset: currentState.currentOffset,
      );

      final updatedConversations = [
        ...currentState.conversations!,
        ...moreConversations,
      ];

      final hasMore = moreConversations.length >= _pageSize;

      state = AsyncValue.data(
        ConversationListState.normal(
          updatedConversations,
          hasMore: hasMore,
          offset: currentState.currentOffset + moreConversations.length,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
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
      final hasMore = results.results.length >= limit;
      return ConversationListState.search(
        results,
        hasMore: hasMore,
        offset: offset + results.results.length,
      );
    });
  }

  Future<void> loadMoreSearchResults(String query) async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isSearchMode ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final moreResults = await repository.searchConversations(
        query: query,
        limit: _pageSize,
        offset: currentState.currentOffset,
      );

      final updatedResults = ConversationSearchResults(
        results: [
          ...currentState.searchResults!.results,
          ...moreResults.results,
        ],
        total: moreResults.total,
        query: query,
      );

      final hasMore = moreResults.results.length >= _pageSize;

      state = AsyncValue.data(
        ConversationListState.search(
          updatedResults,
          hasMore: hasMore,
          offset: currentState.currentOffset + moreResults.results.length,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clear() {
    state = const AsyncValue.loading();
  }
}
