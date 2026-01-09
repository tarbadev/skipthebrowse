import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/core/widgets/grain_overlay.dart';
import 'package:skipthebrowse/features/auth/domain/providers/auth_providers.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/add_message_widget.dart';
import 'package:skipthebrowse/features/search/domain/providers/search_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _createSearchSession(
    String message,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final session = await ref
        .read(searchSessionProvider.notifier)
        .createSession(message);

    if (session != null && context.mounted) {
      AppRoutes.goToSearchSession(context, session);
    }
  }

  Widget _buildConversationStarters(
    BuildContext context,
    List<(String, String, String)> starters,
    bool isLoading,
    WidgetRef ref,
  ) {
    final responsive = context.responsive;
    final columns = responsive.gridColumns;

    if (columns == 1) {
      // Single column layout for mobile
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: starters.asMap().entries.map((entry) {
          final index = entry.key;
          final (emoji, label, prompt) = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GlowingStarterCard(
                emoji: emoji,
                label: label,
                prompt: prompt,
                isLoading: isLoading,
                onTap: () => _createSearchSession(prompt, ref, context),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Grid layout for tablet and desktop
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: starters.asMap().entries.map((entry) {
        final index = entry.key;
        final (emoji, label, prompt) = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: SizedBox(
            width:
                (responsive.width -
                    responsive.horizontalPadding.horizontal -
                    (16 * (columns - 1))) /
                columns,
            child: _GlowingStarterCard(
              emoji: emoji,
              label: label,
              prompt: prompt,
              isLoading: isLoading,
              onTap: () => _createSearchSession(prompt, ref, context),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(searchSessionProvider);
    final isLoading = sessionState.isLoading;
    final authState = ref.watch(authStateProvider);
    final responsive = context.responsive;

    final conversationStarters = [
      ("🎬", "Something thrilling", "I want something thrilling to watch"),
      ("😂", "Comedy to binge", "Looking for a comedy series to binge"),
      ("🧠", "Like Inception", "Recommend me something like Inception"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'SkipTheBrowse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.movie_filter_rounded,
                color: Colors.white70,
              ),
              onPressed: () => AppRoutes.goToRecommendationHistory(context),
              tooltip: 'My Recommendations',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.history_rounded, color: Colors.white70),
              onPressed: () => AppRoutes.goToConversationList(context),
              tooltip: 'View past conversations',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: authState.when(
              data: (session) {
                final isAnonymous = session?.user.isAnonymous ?? true;
                return IconButton(
                  tooltip: 'Account',
                  icon: Icon(
                    isAnonymous ? Icons.person_outline : Icons.person,
                    color: Colors.white70,
                    size: 24,
                  ),
                  onPressed: () => AppRoutes.goToAccountSettings(context),
                );
              },
              loading: () => IconButton(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
                onPressed: null,
              ),
              error: (error, stack) => IconButton(
                icon: const Icon(Icons.error_outline, color: Colors.red),
                onPressed: () => AppRoutes.goToAccountSettings(context),
                tooltip: 'Account (Error)',
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.5),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF242424).withValues(alpha: 0.6),
                    const Color(0xFF181818),
                  ],
                ),
              ),
            ),
          ),
          const GrainOverlay(opacity: 0.03, density: 0.4),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      responsive.height -
                      MediaQuery.of(context).padding.vertical,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: responsive.contentMaxWidth ?? responsive.width,
                    ),
                    child: Padding(
                      padding: responsive.horizontalPadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hero section
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFFFFFFFF),
                                          Color(0xFFE0E0E0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ).createShader(bounds),
                                  child: Text(
                                    'Looking for something to watch?',
                                    key: const Key('home_page_title'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(48),
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                      letterSpacing: -1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Let AI be your personal curator',
                                  style: TextStyle(
                                    fontSize: responsive.fontSize(16),
                                    color: Colors.white.withValues(alpha: 0.5),
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.spacing * 2.5),

                          // Search bar first
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  'Start your conversation:',
                                  style: TextStyle(
                                    fontSize: responsive.fontSize(14),
                                    color: Colors.white.withValues(alpha: 0.4),
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: responsive.spacing),
                                AddMessageWidget(
                                  onSubmit: (String message) =>
                                      _createSearchSession(
                                        message,
                                        ref,
                                        context,
                                      ),
                                  isLoading: isLoading,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: responsive.spacing * 2),

                          // Quick starters below
                          if (!isLoading) ...[
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1200),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Or try a quick starter:',
                                        style: TextStyle(
                                          fontSize: responsive.fontSize(14),
                                          color: Colors.white.withValues(
                                            alpha: 0.4,
                                          ),
                                          letterSpacing: 1.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: responsive.spacing),
                                      _buildConversationStarters(
                                        context,
                                        conversationStarters,
                                        isLoading,
                                        ref,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ] else
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withValues(alpha: 0.15),
                                    ),
                                    child: const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF6366F1),
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Finding the perfect match...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingStarterCard extends StatefulWidget {
  final String emoji;
  final String label;
  final String prompt;
  final bool isLoading;
  final VoidCallback onTap;

  const _GlowingStarterCard({
    required this.emoji,
    required this.label,
    required this.prompt,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_GlowingStarterCard> createState() => _GlowingStarterCardState();
}

class _GlowingStarterCardState extends State<_GlowingStarterCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final emojiSize = responsive.responsive(
      mobile: 40.0,
      tablet: 44.0,
      desktop: 48.0,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.borderRadius),
            color: _isHovered
                ? const Color(0xFF2A2A2A)
                : const Color(0xFF242424),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.responsive(
                mobile: 20.0,
                tablet: 22.0,
                desktop: 24.0,
              ),
              vertical: responsive.responsive(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: emojiSize,
                  height: emojiSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: TextStyle(
                        fontSize: responsive.responsive(
                          mobile: 20.0,
                          tablet: 22.0,
                          desktop: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: responsive.responsive(
                    mobile: 12.0,
                    tablet: 14.0,
                    desktop: 16.0,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.prompt,
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: _isHovered
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: _isHovered
                      ? const Color(0xFF6366F1)
                      : Colors.white.withValues(alpha: 0.3),
                  size: responsive.responsive(
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
