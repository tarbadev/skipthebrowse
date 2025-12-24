import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/pending_message.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_notifier.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';

void main() {
  late ConversationNotifier subject;

  setUpAll(() {
    registerFallbackValue(
      PendingMessage(
        conversationId: 'test',
        content: 'test',
        timestamp: DateTime.now(),
      ),
    );
  });

  setUp(() {
    reset(mockConversationRepository);
    reset(mockPendingMessageQueue);

    when(
      () => mockPendingMessageQueue.enqueue(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockPendingMessageQueue.remove(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockPendingMessageQueue.getForConversation(any()),
    ).thenAnswer((_) async => []);

    subject = ConversationNotifier(
      mockConversationRepository,
      mockPendingMessageQueue,
    );
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
      expect(states[0].isLoading, isTrue);
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
      expect(states[0].isLoading, isTrue);
      expect(states[1], isA<AsyncError>());

      final errorState = subject.state as AsyncError;
      expect(errorState.error, exception);
    });

    test('clears state', () {
      subject.clear();
      expect(subject.state, const AsyncValue<Conversation?>.data(null));
    });

    test(
      'sets state with pending message then data on successful addMessage',
      () async {
        final initialConversation = conversation();
        final expectedConversation = conversation();
        final message = 'Tell me more';
        final states = <AsyncValue<Conversation?>>[];

        subject.setConversation(initialConversation);

        when(
          () => mockConversationRepository.addMessage(any(), any()),
        ).thenAnswer((_) async => expectedConversation);

        subject.addListener((state) {
          states.add(state);
        });

        await subject.addMessage(conversationId, message);

        expect(states.length, 3);
        expect(states[0].asData?.value, initialConversation);
        expect(states[1].asData?.value, isNotNull);
        expect(states[2].asData?.value, expectedConversation);
        expect(subject.state.asData?.value, expectedConversation);

        verify(
          () => mockConversationRepository.addMessage(conversationId, message),
        ).called(1);
        verify(() => mockPendingMessageQueue.enqueue(any())).called(1);
        verify(() => mockPendingMessageQueue.remove(any())).called(1);
      },
    );

    test('sets state with failed message on failed addMessage', () async {
      final initialConversation = conversation();
      final message = 'Tell me more';
      final exception = Exception('Network error');
      final states = <AsyncValue<Conversation?>>[];

      subject.setConversation(initialConversation);

      when(
        () => mockConversationRepository.addMessage(any(), any()),
      ).thenThrow(exception);

      subject.addListener((state) {
        states.add(state);
      });

      await subject.addMessage(conversationId, message);

      expect(states.length, 3);
      expect(states[0].asData?.value, initialConversation);
      expect(states[1].asData?.value, isNotNull);
      expect(states[2].asData?.value, isNotNull);

      final finalConversation = states[2].asData?.value;
      expect(finalConversation, isNotNull);

      verify(
        () => mockConversationRepository.addMessage(conversationId, message),
      ).called(1);
      verify(() => mockPendingMessageQueue.enqueue(any())).called(1);
      verifyNever(() => mockPendingMessageQueue.remove(any()));
    });

    test('sets conversation directly', () {
      final testConversation = conversation();
      subject.setConversation(testConversation);
      expect(subject.state.asData?.value, testConversation);
    });
  });
}
