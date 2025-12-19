import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/state/conversation_list_notifier.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_factory.dart';

void main() {
  late ConversationListNotifier subject;

  setUp(() {
    subject = ConversationListNotifier(mockConversationRepository);
  });

  group('ConversationListNotifier', () {
    test('initial state is AsyncValue.loading()', () {
      expect(
        subject.state,
        const AsyncValue<List<ConversationSummary>>.loading(),
      );
    });

    test('sets state to loading then data on successful load', () async {
      final expectedSummaries = [
        conversationSummary(id: '1'),
        conversationSummary(id: '2'),
      ];
      when(
        () => mockConversationRepository.listConversations(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => expectedSummaries);

      final states = <AsyncValue<List<ConversationSummary>>>[];
      subject.addListener((state) {
        states.add(state);
      });

      await subject.loadConversations();

      expect(states.length, 2);
      expect(states[0].isLoading, isTrue);
      expect(states[1].asData?.value, expectedSummaries);
      expect(subject.state.asData?.value, expectedSummaries);
    });

    test('sets state to loading then error on failed load', () async {
      final exception = Exception('Network error');
      when(
        () => mockConversationRepository.listConversations(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(exception);

      final states = <AsyncValue<List<ConversationSummary>>>[];
      subject.addListener((state) {
        states.add(state);
      });

      await subject.loadConversations();

      expect(states.length, 2);
      expect(states[0].isLoading, isTrue);
      expect(states[1].hasError, isTrue);
      expect(subject.state.hasError, isTrue);
    });

    test('loads conversations with custom limit and offset', () async {
      final expectedSummaries = [conversationSummary(id: '3')];
      when(
        () =>
            mockConversationRepository.listConversations(limit: 10, offset: 20),
      ).thenAnswer((_) async => expectedSummaries);

      await subject.loadConversations(limit: 10, offset: 20);

      verify(
        () =>
            mockConversationRepository.listConversations(limit: 10, offset: 20),
      ).called(1);
      expect(subject.state.asData?.value, expectedSummaries);
    });

    test('clear resets state to loading', () async {
      final expectedSummaries = [conversationSummary(id: '1')];
      when(
        () => mockConversationRepository.listConversations(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => expectedSummaries);

      await subject.loadConversations();
      expect(subject.state.hasValue, isTrue);

      subject.clear();

      expect(
        subject.state,
        const AsyncValue<List<ConversationSummary>>.loading(),
      );
    });
  });
}
