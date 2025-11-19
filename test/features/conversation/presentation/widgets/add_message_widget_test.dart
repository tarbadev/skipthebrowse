import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/add_message_widget.dart';

import '../../../../helpers/test_harness.dart';
import '../helpers/add_message_widget_helper.dart';

void main() {
  final expectedMessage = 'What movies do you recommend?';

  testWidgets('renders widget', (tester) async {
    await tester.pumpProviderWidget(
      AddMessageWidget(onSubmit: (_) => {}, isLoading: false),
    );
    final addMessageWidgetHelper = AddMessageWidgetHelper(tester);
    addMessageWidgetHelper.isVisible();
  });

  testWidgets('button is enabled after entering text', (tester) async {
    await tester.pumpProviderWidget(
      AddMessageWidget(onSubmit: (_) => {}, isLoading: false),
    );
    final addMessageWidgetHelper = AddMessageWidgetHelper(tester);

    IconButton button = addMessageWidgetHelper.getButton();
    expect(button.onPressed, isNull);

    await addMessageWidgetHelper.enterMessage(expectedMessage);

    button = addMessageWidgetHelper.getButton();
    expect(button.onPressed, isNotNull);
  });

  testWidgets('calls onSubmit callback on submit tap', (tester) async {
    var onSubmitInvoked = false;

    await tester.pumpProviderWidget(
      AddMessageWidget(
        onSubmit: (message) {
          onSubmitInvoked = true;
          expect(message, expectedMessage);
        },
        isLoading: false,
      ),
    );

    final addMessageWidgetHelper = AddMessageWidgetHelper(tester);

    await addMessageWidgetHelper.enterMessage(expectedMessage);
    await addMessageWidgetHelper.submit();

    expect(onSubmitInvoked, isTrue);
  });

  testWidgets('shows error when input is too short', (tester) async {
    await tester.pumpProviderWidget(
      AddMessageWidget(onSubmit: (_) => {}, isLoading: false),
    );

    final addMessageWidgetHelper = AddMessageWidgetHelper(tester);
    await addMessageWidgetHelper.enterMessage('Short');
    await addMessageWidgetHelper.submit();

    expect(find.text('Message must be at least 10 characters'), findsOneWidget);
  });

  testWidgets('shows error when input is too long', (tester) async {
    await tester.pumpProviderWidget(
      AddMessageWidget(onSubmit: (_) => {}, isLoading: false),
    );

    final addMessageWidgetHelper = AddMessageWidgetHelper(tester);
    final longText = 'a' * 501;

    await addMessageWidgetHelper.enterMessage(longText);
    await addMessageWidgetHelper.submit();

    expect(find.text('Message must not exceed 500 characters'), findsOneWidget);
  });

  testWidgets('does not call onSubmit callback when validation fails', (
    tester,
  ) async {
    var onSubmitInvoked = false;
    var expectedMessage = 'Short';

    await tester.pumpProviderWidget(
      AddMessageWidget(
        onSubmit: (message) {
          onSubmitInvoked = true;
          expect(message, expectedMessage);
        },
        isLoading: false,
      ),
    );

    final addMessageWidgetHelper = AddMessageWidgetHelper(tester);
    await addMessageWidgetHelper.enterMessage(expectedMessage);
    await addMessageWidgetHelper.submit();

    expect(onSubmitInvoked, isFalse);
  });
}

class MockOnSubmitCallback extends Mock {
  void call(Conversation value);
}
