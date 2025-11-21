import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_notifier.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';

void main() {
  late ConversationNotifier subject;

  setUp(() {
    subject = ConversationNotifier(mockConversationRepository);
  });

  group('ConversationNotifier', () {
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

    test('sets state to loading then data on successful addMessage', () async {
      final expectedConversation = conversation();
      final message = 'Tell me more';
      final states = <AsyncValue<Conversation?>>[];

      when(
        () => mockConversationRepository.addMessage(any(), any()),
      ).thenAnswer((_) async => expectedConversation);

      subject.addListener((state) {
        if (state != const AsyncValue<Conversation?>.data(null)) {
          states.add(state);
        }
      });

      await subject.addMessage(conversationId, message);

      expect(states.length, 2);
      expect(states[0], isA<AsyncLoading>());
      expect(states[1].asData?.value, expectedConversation);
      expect(subject.state.asData?.value, expectedConversation);

      verify(
        () => mockConversationRepository.addMessage(conversationId, message),
      ).called(1);
    });

    test('sets state to loading then error on failed addMessage', () async {
      final message = 'Tell me more';
      final exception = Exception('Network error');
      final states = <AsyncValue<Conversation?>>[];

      when(
        () => mockConversationRepository.addMessage(any(), any()),
      ).thenThrow(exception);

      subject.addListener((state) {
        if (state != const AsyncValue<Conversation?>.data(null)) {
          states.add(state);
        }
      });

      await subject.addMessage(conversationId, message);

      expect(states.length, 2);
      expect(states[0], isA<AsyncLoading>());
      expect(states[1], isA<AsyncError>());

      final errorState = subject.state as AsyncError;
      expect(errorState.error, exception);

      verify(
        () => mockConversationRepository.addMessage(conversationId, message),
      ).called(1);
    });

    test('sets conversation directly', () {
      final testConversation = conversation();
      subject.setConversation(testConversation);
      expect(subject.state.asData?.value, testConversation);
    });
  });
}
