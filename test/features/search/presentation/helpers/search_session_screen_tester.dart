import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/recommendation_widget.dart';
import 'package:skipthebrowse/features/search/presentation/widgets/interaction_prompt_widget.dart';

import '../../../../helpers/base_screen_tester.dart';

class SearchSessionScreenTester extends BaseWidgetTester {
  String titleKey = 'search_session_screen_title';
  String textBoxKey = 'add_message_text_box';
  String buttonKey = 'add_message_button';

  SearchSessionScreenTester(super.tester);

  bool get isVisible => widgetExists(titleKey);

  String get title => getTextByKey(titleKey);

  Future<void> waitForIsVisible() async {
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (isVisible) {
        return;
      }
    }
    expect(find.byKey(Key(titleKey)), findsOneWidget);
  }

  List<String> getSearchSession() {
    final List<String> messages = [];

    // 1. Add initial message if it exists
    final initialMessageFinder = find.byKey(
      const Key('search_session_initial_message'),
    );
    if (tester.any(initialMessageFinder)) {
      final initialMessageWidget = tester.widget<Text>(initialMessageFinder);
      messages.add(initialMessageWidget.data!);
    }

    // 2. Find all interaction Columns (they have keys like 'interaction_{id}')
    final allColumns = find.byType(Column, skipOffstage: false);
    final interactionColumns = <Column>[];

    for (var columnElement in tester.widgetList<Column>(allColumns)) {
      if (columnElement.key != null) {
        final key = columnElement.key;
        if (key is ValueKey &&
            key.value.toString().startsWith('interaction_')) {
          interactionColumns.add(columnElement);
        }
      }
    }

    // 3. For each interaction Column, extract the prompt and response
    for (var column in interactionColumns) {
      // Find InteractionPromptWidget within this column
      final promptWidgets = column.children
          .whereType<InteractionPromptWidget>()
          .toList();

      if (promptWidgets.isNotEmpty) {
        messages.add(promptWidgets.first.prompt.promptPrefix);
      }

      // Find user response Text widget within this column
      // It's nested in Padding > Align > Container > Text
      // The Text has key 'user_response_{id}'
      final keyString = (column.key as ValueKey).value.toString();
      final interactionId = keyString.replaceFirst('interaction_', '');
      final userResponseKey = Key('user_response_$interactionId');
      final userResponseFinder = find.descendant(
        of: find.byWidget(column),
        matching: find.byKey(userResponseKey),
      );

      if (tester.any(userResponseFinder)) {
        final userResponseWidget = tester.widget<Text>(userResponseFinder);
        if (userResponseWidget.data != null) {
          messages.add(userResponseWidget.data!);
        }
      }
    }

    return messages;
  }

  List<Map<String, dynamic>> getRecommendations() {
    final Finder recommendationFinders = find.byType(
      RecommendationWidget,
      skipOffstage: false,
    );
    final List<Map<String, dynamic>> recommendations = [];

    for (final element in recommendationFinders.evaluate()) {
      final widget = element.widget as RecommendationWidget;
      final recommendation = widget.recommendation;
      final recommendationId = recommendation.id;

      final title = getTextByKey('recommendation_${recommendationId}_title');
      final description = getTextByKey(
        'recommendation_${recommendationId}_description',
      );
      final releaseYear = int.parse(
        getTextByKey('recommendation_${recommendationId}_release_year'),
      );
      final rating = double.parse(
        getTextByKey('recommendation_${recommendationId}_rating'),
      );

      // Get confidence directly from entity (already in decimal format 0.0-1.0)
      final confidence = recommendation.confidence;

      // Get platforms directly from the recommendation entity
      final platforms = recommendation.platforms
          .map((platform) => {'name': platform.name, 'url': platform.url})
          .toList();

      recommendations.add({
        'title': title,
        'description': description,
        'releaseYear': releaseYear,
        'rating': rating,
        'confidence': confidence,
        'platforms': platforms,
      });
    }

    return recommendations;
  }

  Future<void> addMessage(String choiceText) async {
    // Find and tap the choice button with matching text
    // The choice buttons are ElevatedButtons with Text children
    final choiceFinder = find.widgetWithText(ElevatedButton, choiceText);
    expect(
      choiceFinder,
      findsOneWidget,
      reason: 'Could not find choice button with text: $choiceText',
    );
    await tester.tap(choiceFinder);
    await tester.pumpAndSettle();

    // After selecting a choice, a "Continue" button should appear
    final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(
      continueFinder,
      findsOneWidget,
      reason: 'Continue button not found after selecting choice',
    );
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();
  }
}
