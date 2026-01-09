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
    final Finder messageFinders = find.byType(
      InteractionPromptWidget,
      skipOffstage: false,
    );
    return tester
        .widgetList<InteractionPromptWidget>(messageFinders)
        .map((widget) => widget.prompt.promptPrefix)
        .toList();
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

  Future<void> addMessage(String response) async {
    expect(find.byKey(Key(textBoxKey)), findsOneWidget);
    await enterText(textBoxKey, response);
    await tester.pump();

    expect(find.byKey(Key(buttonKey)), findsOneWidget);
    await tapOnWidgetByKey(buttonKey);
  }
}
