import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for StateNotifiers that manage AsyncValue state
///
/// Eliminates boilerplate code for loading/error handling patterns.
/// Provides consistent error handling across all notifiers.
abstract class BaseAsyncNotifier<T> extends StateNotifier<AsyncValue<T>> {
  BaseAsyncNotifier(super.initialState);

  /// Execute an async operation with automatic loading/error handling
  ///
  /// Sets state to loading, executes the operation, then sets state to data or error.
  ///
  /// Example:
  /// ```dart
  /// Future<void> fetchData() => execute(
  ///   () => repository.getData(),
  /// );
  /// ```
  Future<void> execute(
    Future<T> Function() operation, {
    bool keepPrevious = false,
  }) async {
    state = keepPrevious
        ? AsyncLoading<T>().copyWithPrevious(state)
        : AsyncLoading<T>();

    try {
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (err, stack) {
      state = keepPrevious
          ? AsyncError<T>(err, stack).copyWithPrevious(state)
          : AsyncError<T>(err, stack);
    }
  }

  /// Execute an async operation with optimistic update
  ///
  /// Updates state optimistically before the operation, then reverts on error.
  ///
  /// Example:
  /// ```dart
  /// Future<void> updateItem(Item newItem) => executeWithOptimisticUpdate(
  ///   optimisticState: state.value?.copyWith(item: newItem),
  ///   operation: () => repository.updateItem(newItem),
  /// );
  /// ```
  Future<void> executeWithOptimisticUpdate({
    required T? optimisticState,
    required Future<void> Function() operation,
  }) async {
    final previousState = state.value;
    if (optimisticState == null) return;

    // Apply optimistic update
    state = AsyncValue.data(optimisticState);

    try {
      await operation();
      // Keep optimistic state if operation succeeds
    } catch (err, stack) {
      // Revert to previous state on error
      state = previousState != null
          ? AsyncError<T>(
              err,
              stack,
            ).copyWithPrevious(AsyncValue.data(previousState))
          : AsyncError<T>(err, stack);
    }
  }

  /// Execute an async operation and apply a transform to the result
  ///
  /// Useful when the operation returns a different type than the state.
  ///
  /// Example:
  /// ```dart
  /// Future<void> fetchAndTransform() => executeWithTransform(
  ///   operation: () => repository.getRawData(),
  ///   transform: (rawData) => transformToState(rawData),
  /// );
  /// ```
  Future<void> executeWithTransform<R>({
    required Future<R> Function() operation,
    required T Function(R) transform,
    bool keepPrevious = false,
  }) async {
    state = keepPrevious
        ? AsyncLoading<T>().copyWithPrevious(state)
        : AsyncLoading<T>();

    try {
      final result = await operation();
      state = AsyncValue.data(transform(result));
    } catch (err, stack) {
      state = keepPrevious
          ? AsyncError<T>(err, stack).copyWithPrevious(state)
          : AsyncError<T>(err, stack);
    }
  }

  /// Execute an async operation that returns the new state with loading indicator
  ///
  /// Shows loading state with previous data preserved.
  ///
  /// Example:
  /// ```dart
  /// Future<void> refresh() => executeWithPrevious(
  ///   () => repository.getData(),
  /// );
  /// ```
  Future<void> executeWithPrevious(Future<T> Function() operation) =>
      execute(operation, keepPrevious: true);
}
