import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/network/dio_provider.dart';
import 'package:skipthebrowse/features/search/data/repositories/api_search_repository.dart';
import 'package:skipthebrowse/features/search/data/repositories/search_rest_client.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';
import 'package:skipthebrowse/features/search/domain/state/search_session_notifier.dart';
import 'package:skipthebrowse/features/search/domain/state/recommendation_history_notifier.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final restClient = SearchRestClient(dio, baseUrl: dio.options.baseUrl);

  return ApiSearchRepository(restClient: restClient);
});

final searchSessionProvider =
    StateNotifierProvider<SearchSessionNotifier, AsyncValue<SearchSession?>>((
      ref,
    ) {
      return SearchSessionNotifier(ref.watch(searchRepositoryProvider));
    });

final recommendationHistoryProvider =
    StateNotifierProvider<
      RecommendationHistoryNotifier,
      AsyncValue<RecommendationHistoryState>
    >((ref) {
      return RecommendationHistoryNotifier(ref.watch(searchRepositoryProvider));
    });
