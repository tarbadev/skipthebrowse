import 'package:equatable/equatable.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';

class SearchResult extends Equatable {
  final ConversationSummary summary;
  final String matchedContent;
  final double rank;

  const SearchResult({
    required this.summary,
    required this.matchedContent,
    required this.rank,
  });

  @override
  List<Object?> get props => [summary, matchedContent, rank];
}

class ConversationSearchResults extends Equatable {
  final List<SearchResult> results;
  final int total;
  final String query;

  const ConversationSearchResults({
    required this.results,
    required this.total,
    required this.query,
  });

  @override
  List<Object?> get props => [results, total, query];
}
