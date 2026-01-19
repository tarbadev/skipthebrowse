import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/state/base_async_notifier.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';

class SearchSessionNotifier extends BaseAsyncNotifier<SearchSession?> {
  final SearchRepository repository;

  SearchSessionNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<SearchSession?> createSession(
    String initialMessage, {
    String region = 'US',
  }) async {
    await executeWithPrevious(
      () => repository.createSearchSession(initialMessage, region: region),
    );
    return state.value;
  }

  Future<void> addInteraction(
    String sessionId,
    String choiceId, {
    String? customInput,
  }) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Safety check: Ensure interactions list is not empty
    if (currentSession.interactions.isEmpty) return;

    final lastInteraction = currentSession.interactions.last;
    final choices = lastInteraction.assistantPrompt.choices;

    // Safety check: Ensure choices list is not empty
    if (choices.isEmpty) return;

    // Find the display text for the selected choice
    final selectedChoice = choices.firstWhere(
      (c) => c.id == choiceId,
      orElse: () => choices.first,
    );

    // Build user input with display text (not ID)
    final userInputText = customInput != null
        ? '${selectedChoice.displayText}: $customInput'
        : selectedChoice.displayText;

    // Optimistic update: Update last interaction with user's response
    final updatedInteractions = List<Interaction>.from(
      currentSession.interactions,
    );
    updatedInteractions[updatedInteractions.length - 1] = Interaction(
      id: updatedInteractions.last.id,
      userInput: userInputText,
      assistantPrompt: updatedInteractions.last.assistantPrompt,
      timestamp: updatedInteractions.last.timestamp,
    );

    final updatedSession = SearchSession(
      id: currentSession.id,
      initialMessage: currentSession.initialMessage,
      interactions: updatedInteractions,
      recommendations: currentSession.recommendations,
      createdAt: currentSession.createdAt,
    );

    // Optimistic update with revert on error
    await executeWithOptimisticUpdate(
      optimisticState: updatedSession,
      operation: () => repository
          .addInteraction(sessionId, choiceId, customInput: customInput)
          .then((session) {
            // Update with actual server response
            state = AsyncValue.data(session);
          }),
    );
  }

  Future<void> refreshSession(String sessionId) =>
      executeWithPrevious(() => repository.getSearchSession(sessionId));

  void setSession(SearchSession session) {
    state = AsyncValue.data(session);
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
