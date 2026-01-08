import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/presentation/widgets/interaction_prompt_widget.dart';
import 'package:skipthebrowse/features/search/presentation/widgets/recommendation_card_with_status.dart';

class SearchSessionScreen extends ConsumerStatefulWidget {
  final SearchSession session;

  const SearchSessionScreen({super.key, required this.session});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchSessionScreenState();
}

class _SearchSessionScreenState extends ConsumerState<SearchSessionScreen> {
  final ScrollController _scrollController = ScrollController();
  // TODO: Re-enable when state management tracks interaction updates
  // int _previousInteractionCount = 0;

  @override
  void initState() {
    super.initState();
    // _previousInteractionCount = widget.session.interactions.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLastInteraction();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLastInteraction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final interactionCount = widget.session.interactions.length;
      if (interactionCount == 0) return;

      // Calculate position to show last interaction at top of viewport
      final viewportHeight = _scrollController.position.viewportDimension;
      final estimatedInteractionHeight = 120.0; // Approximate height
      final targetOffset = max(
        0.0,
        _scrollController.position.maxScrollExtent -
            viewportHeight +
            estimatedInteractionHeight +
            100,
      );

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleInteractionSubmit(String choiceId, String? customInput) {
    // TODO: Implement interaction submission via state management
    // ref.read(searchSessionProvider.notifier).addInteraction(...)
  }

  void _handleStatusChange(String recommendationId, status) {
    // TODO: Implement status update via state management
    // ref.read(searchSessionProvider.notifier).updateRecommendationStatus(...)
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final session = widget.session;

    // TODO: Watch search session state
    // final sessionState = ref.watch(searchSessionProvider);
    // final currentSession = sessionState.value ?? widget.session;

    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818).withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.responsive(
              mobile: 10.0,
              tablet: 12.0,
              desktop: 12.0,
            ),
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Search Session',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Atmospheric background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.5,
                  colors: [
                    const Color(0xFF242424).withValues(alpha: 0.6),
                    const Color(0xFF181818),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          responsive.centerMaxWidth(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: responsive.responsive(
                  mobile: 100.0,
                  tablet: 110.0,
                  desktop: 120.0,
                ),
                bottom: 20,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount:
                  session.interactions.length + session.recommendations.length,
              itemBuilder: (context, index) {
                // Show interactions first, then recommendations
                if (index < session.interactions.length) {
                  final interaction = session.interactions[index];
                  return Column(
                    key: Key('interaction_${interaction.id}'),
                    children: [
                      // Show user input if exists
                      if (interaction.userInput != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.responsive(
                              mobile: 16.0,
                              tablet: 20.0,
                              desktop: 24.0,
                            ),
                            vertical: responsive.responsive(
                              mobile: 8.0,
                              tablet: 10.0,
                              desktop: 12.0,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    responsive.width *
                                    responsive.responsive(
                                      mobile: 0.8,
                                      tablet: 0.7,
                                      desktop: 0.6,
                                    ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.responsive(
                                  mobile: 16.0,
                                  tablet: 18.0,
                                  desktop: 20.0,
                                ),
                                vertical: responsive.responsive(
                                  mobile: 12.0,
                                  tablet: 14.0,
                                  desktop: 16.0,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                    responsive.borderRadius,
                                  ),
                                  topRight: Radius.circular(
                                    responsive.borderRadius,
                                  ),
                                  bottomLeft: Radius.circular(
                                    responsive.borderRadius,
                                  ),
                                  bottomRight: const Radius.circular(4),
                                ),
                              ),
                              child: Text(
                                interaction.userInput!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.fontSize(15),
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Show assistant prompt
                      InteractionPromptWidget(
                        prompt: interaction.assistantPrompt,
                        onSubmit: _handleInteractionSubmit,
                        isEnabled: index == session.interactions.length - 1,
                      ),
                    ],
                  );
                } else {
                  // Show recommendation
                  final recIndex = index - session.interactions.length;
                  final recommendation = session.recommendations[recIndex];
                  return RecommendationCardWithStatus(
                    recommendation: recommendation,
                    onStatusChange: (status) =>
                        _handleStatusChange(recommendation.id, status),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
