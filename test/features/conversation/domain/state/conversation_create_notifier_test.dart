import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_create_notifier.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';

void main() {
  late ConversationCreateNotifier subject;

  setUp(() {
    subject = ConversationCreateNotifier(mockConversationRepository);
  });

  group('ConversationCreateNotifier', () {
    test('initial state is AsyncValue.data(null)', () {
      expect(subject.state, const AsyncValue<Conversation?>.data(null));
    });

    test('sets state to loading then data on successful creation', () async {
      final expectedConversation = conversation();
      when(
        () => mockConversationRepository.createConversation(any()),
      ).thenAnswer((_) async => expectedConversation);

      final states = <AsyncValue<Conversation?>>[];
      subject.addListener((state) {
        if (state != const AsyncValue<Conversation?>.data(null)) {
          states.add(state);
        }
      });

      await subject.createConversation('What should I watch tonight?');

      expect(states.length, 2);
      expect(states[0], isA<AsyncLoading>());
      expect(states[1].asData?.value, expectedConversation);
      expect(subject.state.asData?.value, expectedConversation);
    });

    test('sets state to loading then error on failed creation', () async {
      final exception = Exception('Network error');
      when(
        () => mockConversationRepository.createConversation(any()),
      ).thenThrow(exception);

      final states = <AsyncValue<Conversation?>>[];
      subject.addListener((state) {
        if (state != const AsyncValue<Conversation?>.data(null)) {
          states.add(state);
        }
      });

      await subject.createConversation('What should I watch tonight?');

      expect(states.length, 2);
      expect(states[0], isA<AsyncLoading>());
      expect(states[1], isA<AsyncError>());

      final errorState = subject.state as AsyncError;
      expect(errorState.error, exception);
    });

    test('clears state', () {
      subject.clear();
      expect(subject.state, const AsyncValue<Conversation?>.data(null));
    });
  });
}
