import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/quick_reply_widget.dart';

import '../../../../helpers/test_harness.dart';

void main() {
  final testReplies = ['Comedy', 'Action', 'Drama'];

  testWidgets('renders widget', (tester) async {
    await tester.pumpProviderWidget(
      QuickReplyWidget(replies: testReplies, onReplyTap: (_) {}),
    );

    expect(find.byType(QuickReplyWidget), findsOneWidget);
  });

  testWidgets('displays all reply buttons', (tester) async {
    await tester.pumpProviderWidget(
      QuickReplyWidget(replies: testReplies, onReplyTap: (_) {}),
    );

    // Verify all buttons are rendered
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);

    // Verify all buttons have proper keys
    expect(find.byKey(const Key('quick_reply_Comedy')), findsOneWidget);
    expect(find.byKey(const Key('quick_reply_Action')), findsOneWidget);
    expect(find.byKey(const Key('quick_reply_Drama')), findsOneWidget);

    // Verify buttons use OutlinedButton
    expect(find.byType(OutlinedButton), findsNWidgets(3));
  });

  testWidgets('calls onReplyTap with correct text when button is tapped', (
    tester,
  ) async {
    String? tappedReply;

    await tester.pumpProviderWidget(
      QuickReplyWidget(
        replies: testReplies,
        onReplyTap: (reply) {
          tappedReply = reply;
        },
      ),
    );

    // Tap the 'Comedy' button
    await tester.tap(find.byKey(const Key('quick_reply_Comedy')));
    await tester.pumpAndSettle();

    expect(tappedReply, equals('Comedy'));
  });

  testWidgets('calls onReplyTap for each button', (tester) async {
    final tappedReplies = <String>[];

    await tester.pumpProviderWidget(
      QuickReplyWidget(
        replies: testReplies,
        onReplyTap: (reply) {
          tappedReplies.add(reply);
        },
      ),
    );

    // Tap each button
    await tester.tap(find.byKey(const Key('quick_reply_Comedy')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quick_reply_Action')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quick_reply_Drama')));
    await tester.pumpAndSettle();

    expect(tappedReplies, equals(['Comedy', 'Action', 'Drama']));
  });

  testWidgets('handles single reply', (tester) async {
    await tester.pumpProviderWidget(
      QuickReplyWidget(replies: const ['Yes'], onReplyTap: (_) {}),
    );

    expect(find.text('Yes'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('handles many replies with wrap layout', (tester) async {
    final manyReplies = [
      'Option 1',
      'Option 2',
      'Option 3',
      'Option 4',
      'Option 5',
    ];

    await tester.pumpProviderWidget(
      QuickReplyWidget(replies: manyReplies, onReplyTap: (_) {}),
    );

    // Verify all buttons are rendered
    for (final reply in manyReplies) {
      expect(find.text(reply), findsOneWidget);
    }

    // Verify Wrap widget is used for responsive layout
    expect(find.byType(Wrap), findsOneWidget);
  });

  testWidgets('renders empty state when no replies', (tester) async {
    await tester.pumpProviderWidget(
      QuickReplyWidget(replies: const [], onReplyTap: (_) {}),
    );

    // Should not render anything or render an empty container
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
