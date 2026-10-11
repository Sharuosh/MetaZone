import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/data/home_repository.dart';
import 'package:meta_zone/screens/home/domain/home_model.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';
import 'package:meta_zone/screens/home/home_controller.dart';
import 'package:meta_zone/screens/home/presentation/widgets/ask_metazone_ai_card.dart';
import 'package:meta_zone/screens/home/presentation/widgets/happening_section.dart';
import 'package:meta_zone/screens/home/presentation/widgets/home_header.dart';
import 'package:meta_zone/screens/home/presentation/widgets/home_search_bar.dart';
import 'package:meta_zone/screens/home/presentation/widgets/home_states.dart';
import 'package:meta_zone/screens/home/presentation/widgets/nearby_places_section.dart';
import 'package:meta_zone/screens/home/presentation/widgets/recommended_section.dart';
import 'package:meta_zone/screens/home/presentation/widgets/what_can_i_do_section.dart';
import 'package:meta_zone/screens/search/search_results_screen.dart';
import 'package:meta_zone/screens/zone/zone_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.onSearch,
    this.onNotifications,
    this.onProfile,
    this.onLocation,
    this.onCategory,
    this.onNearbySeeAll,
    this.onPlace,
    this.onHappeningSeeAll,
    this.onHappening,
    this.onGoal,
    this.onRecommendationSeeAll,
    this.onRecommendation,
    this.onAi,
    super.key,
  });

  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;
  final VoidCallback? onLocation;

  final ValueChanged<HomeCategory>? onCategory;

  final VoidCallback? onNearbySeeAll;
  final ValueChanged<NearbyPlace>? onPlace;

  final VoidCallback? onHappeningSeeAll;
  final ValueChanged<Happening>? onHappening;

  final ValueChanged<GoalAction>? onGoal;

  final VoidCallback? onRecommendationSeeAll;
  final ValueChanged<NearbyPlace>? onRecommendation;

  final VoidCallback? onAi;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();

    _controller = HomeController(
      repository: HomeRepository(),
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading && _controller.data == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: HomeLoading(),
          );
        }

        if (_controller.errorMessage != null &&
            _controller.data == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: HomeErrorState(
                message: _controller.errorMessage!,
                onRetry: _controller.load,
              ),
            ),
          );
        }

        final HomeData? data = _controller.data;

        if (data == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: HomeEmptyState(),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ------------------------------------------------------------
                // HERO + UNIVERSAL SEARCH
                // ------------------------------------------------------------
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      HomeHeader(
                        locationName: data.locationName,
                        backgroundAsset:
                        _controller.governorateBackgroundAsset,
                        // Restore the existing live weather values in HomeController.
                        temperature: _controller.weatherTemperature,
                        weatherLabel: _controller.weatherLabel,
                        weatherIcon: _controller.weatherIcon,
                        onLocationTap: widget.onLocation ?? () {
                          _controller.retryLocation();
                        },
                        onNotificationsTap: widget.onNotifications ?? () {
                          _showComingSoon(context, 'Notifications');
                        },
                        onProfileTap: widget.onProfile ?? () {
                          _showComingSoon(context, 'Profile');
                        },
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: HomeSearchBar(
                          onTap: widget.onSearch ?? () {
                            _openSearch(data);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),

                // ------------------------------------------------------------
                // HOME DISCOVERY CONTENT
                // ------------------------------------------------------------
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _ExploreSection(
                          selectedIndex: _selectedCategory,
                          onSeeAll: () {
                            _openSearch(data);
                          },
                          onSelected: (index) {
                            if (index < 0 ||
                                index >= data.categories.length) {
                              return;
                            }

                            setState(() {
                              _selectedCategory = index;
                            });

                            final HomeCategory category =
                            data.categories[index];
                            widget.onCategory?.call(category);

                            // Categories also lead directly into search.
                            // The query is applied on the Search screen only
                            // when the user taps the search bar or a category
                            // chip inside that screen, keeping this Home tap
                            // backward-compatible with existing callbacks.
                          },
                        ),
                        const SizedBox(height: 22),

                        NearbyPlacesSection(
                          places: data.nearbyPlaces,
                          onSeeAll: widget.onNearbySeeAll ?? () {
                            _openSearch(data);
                          },
                          onPlaceTap: widget.onPlace ?? (place) {
                            _showPlacePreview(context, place);
                          },
                        ),
                        const SizedBox(height: 24),

                        HappeningSection(
                          items: data.happenings,
                          onSeeAll: widget.onHappeningSeeAll ?? () {
                            _openSearch(data);
                          },
                          onItemTap: widget.onHappening ?? (item) {
                            _showHappeningPreview(context, item);
                          },
                        ),
                        const SizedBox(height: 24),

                        RecommendedSection(
                          places: data.recommendations,
                          onSeeAll: widget.onRecommendationSeeAll ?? () {
                            _openSearch(data);
                          },
                          onPlaceTap: widget.onRecommendation ?? (place) {
                            _showPlacePreview(context, place);
                          },
                        ),
                        const SizedBox(height: 24),

                        WhatCanIDoSection(
                          goals: data.goals,
                          onGoalTap: widget.onGoal ?? (goal) {
                            _showGoalPreview(context, goal);
                          },
                        ),
                        const SizedBox(height: 24),

                        AskMetaZoneAiCard(
                          onTap: widget.onAi ?? () {
                            _showComingSoon(context, 'MetaZone AI');
                          },
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // UNIVERSAL SEARCH NAVIGATION
  // ==========================================================================

  Future<void> _openSearch(HomeData data) async {
    final SearchSelection? selection =
    await Navigator.of(context).push<SearchSelection>(
      MaterialPageRoute<SearchSelection>(
        builder: (_) => SearchResultsScreen(
          homeData: data,
          locationName: data.locationName,
        ),
      ),
    );

    if (!mounted || selection == null) return;

    switch (selection.kind) {
      case SearchSelectionKind.place:
        final NearbyPlace? place = selection.place;
        if (place == null) return;

        if (widget.onPlace != null) {
          widget.onPlace!(place);
        } else {
          _showPlacePreview(context, place);
        }
        break;

      case SearchSelectionKind.happening:
        final Happening? item = selection.happening;
        if (item == null) return;

        if (widget.onHappening != null) {
          widget.onHappening!(item);
        } else {
          _showHappeningPreview(context, item);
        }
        break;

      case SearchSelectionKind.action:
        final GoalAction? action = selection.action;
        if (action == null) return;

        if (widget.onGoal != null) {
          widget.onGoal!(action);
        } else {
          _showGoalPreview(context, action);
        }
        break;
    }
  }

  // ==========================================================================
  // TEMPORARY FEEDBACK
  // ==========================================================================

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is connected in the next slice.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================================
  // ZONE PROFILE
  // ==========================================================================

  void _showPlacePreview(BuildContext context, NearbyPlace place) {
    final HomeData? data = _controller.data;

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ZoneProfileScreen(
          place: place,
          locationName: data?.locationName ?? 'Around you',
          happenings: data?.happenings ?? const <Happening>[],
        ),
      ),
    );
  }

  // ==========================================================================
  // HAPPENING PREVIEW
  // ==========================================================================

  void _showHappeningPreview(BuildContext context, Happening item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.heading(
                    size: 22,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.placeName} · ${item.distance}',
                  style: AppTextStyles.bodySmallStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.meta != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.meta!,
                    style: AppTextStyles.bodySmallStyle(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showComingSoon(context, 'Event Details');
                    },
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // GOAL / ACTION PREVIEW
  // ==========================================================================

  void _showGoalPreview(BuildContext context, GoalAction goal) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: AppTextStyles.heading(
                    size: 22,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  goal.subtitle,
                  style: AppTextStyles.bodySmallStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showComingSoon(context, 'Nearby Services');
                    },
                    icon: const Icon(Icons.near_me_rounded),
                    label: const Text('Find Nearby'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// COMPACT EXPLORE STRIP
// ============================================================================

class _ExploreSection extends StatelessWidget {
  const _ExploreSection({
    required this.selectedIndex,
    required this.onSelected,
    required this.onSeeAll,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSeeAll;

  static const List<_ExploreItemData> _items = [
    _ExploreItemData(icon: Icons.near_me_rounded, label: 'Nearby'),
    _ExploreItemData(icon: Icons.restaurant_rounded, label: 'Food'),
    _ExploreItemData(icon: Icons.local_cafe_rounded, label: 'Cafes'),
    _ExploreItemData(icon: Icons.local_hospital_rounded, label: 'Health'),
    _ExploreItemData(icon: Icons.school_rounded, label: 'Education'),
    _ExploreItemData(icon: Icons.shopping_bag_rounded, label: 'Shopping'),
    _ExploreItemData(icon: Icons.more_horiz_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Explore',
                style: AppTextStyles.heading(
                  size: 24,
                  color: AppColors.text,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onSeeAll,
              iconAlignment: IconAlignment.end,
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.primary,
              ),
              label: Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final _ExploreItemData item = _items[index];
              final bool selected = index == selectedIndex;

              return Semantics(
                button: true,
                selected: selected,
                label: item.label,
                child: GestureDetector(
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 78,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFF11182A),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Colors.white.withValues(alpha: 0.16)
                                : const Color(0xFF1B2340),
                          ),
                          child: Icon(
                            item.icon,
                            size: 19,
                            color: selected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFFE7E9F1),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExploreItemData {
  const _ExploreItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
