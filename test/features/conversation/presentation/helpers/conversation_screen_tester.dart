import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/message_widget.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/recommendation_widget.dart';

import 'base_screen_tester.dart';

class ConversationScreenTester extends BaseWidgetTester {
  String titleKey = 'conversation_screen_title';
  String textBoxKey = 'add_message_text_box';
  String buttonKey = 'add_message_button';

  ConversationScreenTester(super.tester);

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

  List<String> getConversation() {
    final Finder messageFinders = find.byType(MessageWidget);
    final Iterable<Widget> textWidgets = messageFinders.evaluate().map(
      (element) => element.widget,
    );

    return textWidgets
        .map((Widget message) => (message as MessageWidget).text)
        .toList();
  }

  List<Map<String, dynamic>> getRecommendations() {
    final Finder recommendationFinders = find.byType(RecommendationWidget);
    final List<Map<String, dynamic>> recommendations = [];

    for (final element in recommendationFinders.evaluate()) {
      final widget = element.widget as RecommendationWidget;
      final recommendationId = widget.recommendation.id;

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
      final confidence = double.parse(
        getTextByKey('recommendation_${recommendationId}_confidence'),
      );

      final platformsCount = int.parse(
        getTextByKey('recommendation_${recommendationId}_platforms_count'),
      );

      final platforms = <Map<String, dynamic>>[];
      for (int i = 0; i < platformsCount; i++) {
        final name = getTextByKey(
          'recommendation_${recommendationId}_platform_${i}_name',
        );
        final url = getTextByKey(
          'recommendation_${recommendationId}_platform_${i}_url',
        );

        platforms.add({'name': name, 'url': url});
      }

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

  Future<void> addMessage(String response) async {
    expect(find.byKey(Key(textBoxKey)), findsOneWidget);
    await enterText(textBoxKey, response);
    await tester.pump();

    expect(find.byKey(Key(buttonKey)), findsOneWidget);
    await tapOnButtonByKey(buttonKey);
  }
}
