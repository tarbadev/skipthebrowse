import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';
import 'package:skipthebrowse/features/search/presentation/widgets/recommendation_card_with_status.dart';

class RecommendationHistoryScreen extends ConsumerStatefulWidget {
  const RecommendationHistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecommendationHistoryScreenState();
}

class _RecommendationHistoryScreenState
    extends ConsumerState<RecommendationHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // TODO: Load recommendations on init
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(recommendationHistoryProvider.notifier).loadHistory();
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // TODO: Re-enable when state management is implemented
  // RecommendationStatus? _getFilterStatus() {
  //   switch (_tabController.index) {
  //     case 0:
  //       return null; // All
  //     case 1:
  //       return RecommendationStatus.willWatch;
  //     case 2:
  //       return RecommendationStatus.seen;
  //     case 3:
  //       return RecommendationStatus.declined;
  //     default:
  //       return null;
  //   }
  // }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    // TODO: Implement search
    // if (query.isNotEmpty) {
    //   ref.read(recommendationHistoryProvider.notifier).search(query);
    // } else {
    //   ref.read(recommendationHistoryProvider.notifier).loadHistory(
    //     status: _getFilterStatus(),
    //   );
    // }
  }

  void _handleStatusChange(
    String recommendationId,
    RecommendationStatus status,
  ) {
    // TODO: Implement status update
    // ref.read(recommendationHistoryProvider.notifier).updateStatus(
    //   recommendationId,
    //   status,
    // );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    // TODO: Watch recommendation history state
    // final historyState = ref.watch(recommendationHistoryProvider);
    // Mock data for now
    final recommendations = <RecommendationWithStatus>[];
    final isLoading = false;
    final hasError = false;

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
            'My Recommendations',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.responsive(
                    mobile: 16.0,
                    tablet: 20.0,
                    desktop: 24.0,
                  ),
                  vertical: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.fontSize(15),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search recommendations...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        responsive.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        responsive.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        responsive.borderRadius,
                      ),
                      borderSide: const BorderSide(
                        color: Color(0xFF6366F1),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: const Color(0xFF6366F1),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                labelStyle: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w600,
                ),
                onTap: (index) {
                  if (_searchQuery.isEmpty) {
                    // TODO: Reload with new filter
                    // ref.read(recommendationHistoryProvider.notifier).loadHistory(
                    //   status: _getFilterStatus(),
                    // );
                  }
                },
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Will Watch'),
                  Tab(text: 'Seen'),
                  Tab(text: 'Declined'),
                ],
              ),
            ],
          ),
        ),
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
          // Content
          TabBarView(
            controller: _tabController,
            children: [
              _buildRecommendationList(
                recommendations,
                isLoading,
                hasError,
                responsive,
              ),
              _buildRecommendationList(
                recommendations,
                isLoading,
                hasError,
                responsive,
              ),
              _buildRecommendationList(
                recommendations,
                isLoading,
                hasError,
                responsive,
              ),
              _buildRecommendationList(
                recommendations,
                isLoading,
                hasError,
                responsive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(
    List<RecommendationWithStatus> recommendations,
    bool isLoading,
    bool hasError,
    ResponsiveUtils responsive,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(
            responsive.responsive(mobile: 24.0, tablet: 32.0, desktop: 40.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: responsive.responsive(
                  mobile: 48.0,
                  tablet: 56.0,
                  desktop: 64.0,
                ),
                color: const Color(0xFFEF4444),
              ),
              SizedBox(
                height: responsive.responsive(
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
              ),
              Text(
                'Failed to load recommendations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: responsive.responsive(
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              Text(
                'Please try again later',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: responsive.fontSize(14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(
            responsive.responsive(mobile: 24.0, tablet: 32.0, desktop: 40.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                size: responsive.responsive(
                  mobile: 48.0,
                  tablet: 56.0,
                  desktop: 64.0,
                ),
                color: Colors.white.withValues(alpha: 0.3),
              ),
              SizedBox(
                height: responsive.responsive(
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
              ),
              Text(
                'No recommendations yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: responsive.responsive(
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              Text(
                'Start a search session to get recommendations',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: responsive.fontSize(14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return responsive.centerMaxWidth(
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: responsive.responsive(mobile: 16.0, tablet: 20.0, desktop: 24.0),
          bottom: 20,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          return RecommendationCardWithStatus(
            recommendation: recommendation,
            onStatusChange: (status) =>
                _handleStatusChange(recommendation.id, status),
          );
        },
      ),
    );
  }
}
