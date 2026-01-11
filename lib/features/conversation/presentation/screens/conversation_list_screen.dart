import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session_summary.dart';
import 'package:skipthebrowse/features/search/domain/providers/search_providers.dart';

final searchSessionListProvider = FutureProvider<List<SearchSessionSummary>>((
  ref,
) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.listSearchSessions();
});

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.symmetric(
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
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // TODO: Implement search for sessions
          setState(() {});
        },
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: responsive.fontSize(15),
        ),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: responsive.fontSize(15),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.5),
            size: responsive.responsive(
              mobile: 20.0,
              tablet: 22.0,
              desktop: 24.0,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: responsive.responsive(
                      mobile: 20.0,
                      tablet: 22.0,
                      desktop: 24.0,
                    ),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsive.responsive(
              mobile: 16.0,
              tablet: 18.0,
              desktop: 20.0,
            ),
            vertical: responsive.responsive(
              mobile: 14.0,
              tablet: 16.0,
              desktop: 18.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(searchSessionListProvider);
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818).withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          tooltip: 'Back',
          onPressed: () => context.pop(),
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
            'My Searches',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(
              right: responsive.responsive(
                mobile: 12.0,
                tablet: 16.0,
                desktop: 16.0,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white70),
              onPressed: () => context.pop(),
              tooltip: 'Start new conversation',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Atmospheric background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF242424).withValues(alpha: 0.6),
                    const Color(0xFF181818),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: responsive.centerMaxWidth(
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: sessionsAsync.when(
                      loading: () => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: responsive.responsive(
                                mobile: 40.0,
                                tablet: 44.0,
                                desktop: 48.0,
                              ),
                              height: responsive.responsive(
                                mobile: 40.0,
                                tablet: 44.0,
                                desktop: 48.0,
                              ),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6366F1),
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.spacing),
                            Text(
                              'Loading search sessions...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: responsive.fontSize(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                responsive.responsive(
                                  mobile: 20.0,
                                  tablet: 22.0,
                                  desktop: 24.0,
                                ),
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: responsive.responsive(
                                  mobile: 48.0,
                                  tablet: 52.0,
                                  desktop: 56.0,
                                ),
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            SizedBox(height: responsive.spacing),
                            Text(
                              'Oops! Something went wrong',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.fontSize(20),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: responsive.horizontalPadding,
                              child: Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: responsive.fontSize(14),
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.spacing),
                            GestureDetector(
                              onTap: () =>
                                  ref.refresh(searchSessionListProvider),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.responsive(
                                    mobile: 24.0,
                                    tablet: 28.0,
                                    desktop: 32.0,
                                  ),
                                  vertical: responsive.responsive(
                                    mobile: 14.0,
                                    tablet: 16.0,
                                    desktop: 18.0,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'Try Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.fontSize(16),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      data: (sessions) {
                        if (sessions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    responsive.responsive(
                                      mobile: 24.0,
                                      tablet: 28.0,
                                      desktop: 32.0,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: responsive.responsive(
                                      mobile: 64.0,
                                      tablet: 72.0,
                                      desktop: 80.0,
                                    ),
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                SizedBox(height: responsive.spacing),
                                Text(
                                  'No search sessions yet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.fontSize(22),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Start a new search to discover\nyour perfect watch',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: responsive.fontSize(15),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(searchSessionListProvider);
                            await ref.read(searchSessionListProvider.future);
                          },
                          backgroundColor: const Color(0xFF242424),
                          color: const Color(0xFF6366F1),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(
                              top: responsive.responsive(
                                mobile: 8.0,
                                tablet: 12.0,
                                desktop: 16.0,
                              ),
                              bottom: 20,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              return _SearchSessionListItem(
                                session: session,
                                key: Key('search_session_item_${session.id}'),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSessionListItem extends ConsumerStatefulWidget {
  final SearchSessionSummary session;

  const _SearchSessionListItem({required this.session, super.key});

  @override
  ConsumerState<_SearchSessionListItem> createState() =>
      _SearchSessionListItemState();
}

class _SearchSessionListItemState
    extends ConsumerState<_SearchSessionListItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: responsive.responsive(
          mobile: 6.0,
          tablet: 8.0,
          desktop: 10.0,
        ),
        horizontal: responsive.responsive(
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(
          responsive.responsive(mobile: 16.0, tablet: 18.0, desktop: 20.0),
        ),
        onTap: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final searchSession = await ref
                      .read(searchRepositoryProvider)
                      .getSearchSession(widget.session.id);

                  if (context.mounted) {
                    AppRoutes.goToSearchSession(context, searchSession);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error loading search session: $e'),
                        backgroundColor: const Color(0xFF242424),
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: responsive.responsive(
                mobile: 24.0,
                tablet: 26.0,
                desktop: 28.0,
              ),
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
              child: Text(
                widget.session.interactionCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (widget.session.recommendationCount > 0)
              Positioned(
                top: responsive.responsive(
                  mobile: -4.0,
                  tablet: -5.0,
                  desktop: -6.0,
                ),
                right: responsive.responsive(
                  mobile: -4.0,
                  tablet: -5.0,
                  desktop: -6.0,
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    responsive.responsive(
                      mobile: 4.0,
                      tablet: 5.0,
                      desktop: 6.0,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF242424),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    widget.session.recommendationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.fontSize(11),
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          widget.session.previewText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: responsive.fontSize(15),
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            _formatTimestamp(widget.session.updatedAt),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: responsive.fontSize(13),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: _isLoading
            ? SizedBox(
                width: responsive.responsive(
                  mobile: 24.0,
                  tablet: 26.0,
                  desktop: 28.0,
                ),
                height: responsive.responsive(
                  mobile: 24.0,
                  tablet: 26.0,
                  desktop: 28.0,
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF6366F1),
                  ),
                ),
              )
            : Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.3),
                size: responsive.responsive(
                  mobile: 24.0,
                  tablet: 26.0,
                  desktop: 28.0,
                ),
              ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Format as "MMM d" (e.g., "Dec 15")
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}';
    }
  }
}
