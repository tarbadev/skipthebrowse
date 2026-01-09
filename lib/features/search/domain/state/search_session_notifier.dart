import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';

class SearchSessionNotifier extends StateNotifier<AsyncValue<SearchSession?>> {
  final SearchRepository repository;

  SearchSessionNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<SearchSession?> createSession(
    String initialMessage, {
    String region = 'US',
  }) async {
    state = const AsyncLoading<SearchSession?>().copyWithPrevious(state);
    try {
      final session = await repository.createSearchSession(
        initialMessage,
        region: region,
      );
      state = AsyncValue.data(session);
      return session;
    } catch (err, stack) {
      state = AsyncError<SearchSession?>(err, stack).copyWithPrevious(state);
      return null;
    }
  }

  Future<void> addInteraction(
    String sessionId,
    String choiceId, {
    String? customInput,
  }) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Find the display text for the selected choice
    final selectedChoice = currentSession
        .interactions
        .last
        .assistantPrompt
        .choices
        .firstWhere(
          (c) => c.id == choiceId,
          orElse: () =>
              currentSession.interactions.last.assistantPrompt.choices.first,
        );

    // Build user input with display text (not ID)
    final userInputText = customInput != null
        ? '${selectedChoice.displayText}: $customInput'
        : selectedChoice.displayText;

    // Optimistic update: Add pending interaction with display text
    final pendingInteraction = Interaction(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      userInput: userInputText,
      assistantPrompt: currentSession.interactions.last.assistantPrompt,
      timestamp: DateTime.now(),
    );

    final updatedSession = SearchSession(
      id: currentSession.id,
      interactions: [...currentSession.interactions, pendingInteraction],
      recommendations: currentSession.recommendations,
      createdAt: currentSession.createdAt,
    );

    // Set loading state while keeping optimistic update
    state = const AsyncLoading<SearchSession?>().copyWithPrevious(
      AsyncValue.data(updatedSession),
    );

    try {
      final session = await repository.addInteraction(
        sessionId,
        choiceId,
        customInput: customInput,
      );
      state = AsyncValue.data(session);
    } catch (err, stack) {
      // Revert to previous state on error
      state = AsyncError<SearchSession?>(
        err,
        stack,
      ).copyWithPrevious(AsyncValue.data(currentSession));
    }
  }

  Future<void> refreshSession(String sessionId) async {
    state = const AsyncLoading<SearchSession?>().copyWithPrevious(state);
    try {
      final session = await repository.getSearchSession(sessionId);
      state = AsyncValue.data(session);
    } catch (err, stack) {
      state = AsyncError<SearchSession?>(err, stack).copyWithPrevious(state);
    }
  }

  void setSession(SearchSession session) {
    state = AsyncValue.data(session);
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
