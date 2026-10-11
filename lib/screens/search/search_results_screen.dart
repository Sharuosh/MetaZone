
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_model.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';

enum SearchSelectionKind {
  place,
  happening,
  action,
}

class SearchSelection {
  const SearchSelection({
    required this.kind,
    this.place,
    this.happening,
    this.action,
  });

  final SearchSelectionKind kind;
  final NearbyPlace? place;
  final Happening? happening;
  final GoalAction? action;
}

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    required this.homeData,
    required this.locationName,
    this.initialQuery = '',
    super.key,
  });

  final HomeData homeData;
  final String locationName;
  final String initialQuery;

  @override
  State<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

enum _SearchKind {
  place,
  happening,
  action,
}

enum _SearchFilter {
  all,
  places,
  happenings,
  actions,
}

enum _SearchSort {
  recommended,
  alphabetical,
}

class _SearchResultsScreenState
    extends State<SearchResultsScreen> {
  static const String _recentStorageKey =
      'metazone_search_recent_v1';

  static const int _maxRecentSearches = 8;

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final List<_SearchEntry> _catalog;

  List<String> _recentSearches = [];

  _SearchFilter _filter = _SearchFilter.all;
  _SearchSort _sort = _SearchSort.recommended;

  String get _query => _searchController.text.trim();

  String get _locationLabel {
    final String value = widget.locationName.trim();

    if (value.isEmpty ||
        value.toLowerCase() == 'around you') {
      return 'you';
    }

    return value;
  }

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.initialQuery,
    );

    _searchFocusNode = FocusNode();

    _catalog = _buildCatalog();

    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SEARCH CATALOG
  // Uses the existing HomeRepository data passed from HomeScreen.
  // ------------------------------------------------------------

  List<_SearchEntry> _buildCatalog() {
    final List<_SearchEntry> results = [];
    final Set<String> seenPlaces = {};

    final places = [
      ...widget.homeData.nearbyPlaces,
      ...widget.homeData.recommendations,
    ];

    for (final NearbyPlace place in places) {
      final String key = _normalize(place.name);

      if (key.isEmpty || !seenPlaces.add(key)) {
        continue;
      }

      results.add(
        _SearchEntry(
          title: place.name,
          subtitle: place.category,
          detailLabel: place.zoneStatus,
          trailingLabel: place.distance,
          kind: _SearchKind.place,
          icon: _iconForCategory(place.category),
          searchText: [
            place.name,
            place.category,
            place.distance,
            place.zoneStatus,
          ].join(' '),
          place: place,
        ),
      );
    }

    for (final Happening item in widget.homeData.happenings) {
      results.add(
        _SearchEntry(
          title: item.title,
          subtitle: item.placeName,
          detailLabel: item.meta ?? '',
          trailingLabel: item.distance,
          kind: _SearchKind.happening,
          icon: Icons.event_available_rounded,
          searchText: [
            item.title,
            item.placeName,
            item.distance,
            item.meta ?? '',
            'event offer activity',
          ].join(' '),
          happening: item,
        ),
      );
    }

    for (final GoalAction goal in widget.homeData.goals) {
      results.add(
        _SearchEntry(
          title: goal.title,
          subtitle: goal.subtitle,
          detailLabel: 'Explore an action',
          trailingLabel: '',
          kind: _SearchKind.action,
          icon: Icons.bolt_rounded,
          searchText: [
            goal.title,
            goal.subtitle,
            'action discover find',
          ].join(' '),
          action: goal,
        ),
      );
    }

    return results;
  }

  // ------------------------------------------------------------
  // FILTERING AND SORTING
  // ------------------------------------------------------------

  List<_SearchEntry> get _visibleResults {
    final String normalizedQuery = _normalize(_query);

    final List<String> terms = normalizedQuery
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();

    final List<_SearchEntry> results =
    _catalog.where((entry) {
      final bool filterMatches = switch (_filter) {
        _SearchFilter.all => true,
        _SearchFilter.places =>
        entry.kind == _SearchKind.place,
        _SearchFilter.happenings =>
        entry.kind == _SearchKind.happening,
        _SearchFilter.actions =>
        entry.kind == _SearchKind.action,
      };

      if (!filterMatches) {
        return false;
      }

      if (terms.isEmpty) {
        return true;
      }

      final String index = _normalize(entry.searchText);

      return terms.every(
            (String term) => index.contains(term),
      );
    }).toList();

    if (_sort == _SearchSort.alphabetical) {
      results.sort(
            (a, b) => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
      );
    }

    return results;
  }

  List<String> get _quickSearches {
    final Set<String> categories = {};

    for (final NearbyPlace place
    in widget.homeData.nearbyPlaces) {
      final String category = place.category.trim();

      if (category.isNotEmpty) {
        categories.add(category);
      }

      if (categories.length >= 5) {
        break;
      }
    }

    return categories.toList();
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(
      RegExp(r'[\u064B-\u065F\u0670]'),
      '',
    )
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static IconData _iconForCategory(String category) {
    final String value = category.toLowerCase();

    if (value.contains('restaurant') ||
        value.contains('food') ||
        value.contains('مطعم') ||
        value.contains('أكل')) {
      return Icons.restaurant_rounded;
    }

    if (value.contains('cafe') ||
        value.contains('coffee') ||
        value.contains('كافيه') ||
        value.contains('قهوة')) {
      return Icons.coffee_rounded;
    }

    if (value.contains('health') ||
        value.contains('hospital') ||
        value.contains('clinic') ||
        value.contains('صحة') ||
        value.contains('مستشفى')) {
      return Icons.health_and_safety_rounded;
    }

    if (value.contains('education') ||
        value.contains('school') ||
        value.contains('university') ||
        value.contains('تعليم') ||
        value.contains('جامعة')) {
      return Icons.school_rounded;
    }

    if (value.contains('shopping') ||
        value.contains('mall') ||
        value.contains('تسوق')) {
      return Icons.shopping_bag_rounded;
    }

    if (value.contains('hotel') ||
        value.contains('فندق')) {
      return Icons.hotel_rounded;
    }

    return Icons.place_rounded;
  }

  // ------------------------------------------------------------
  // RECENT SEARCHES
  // ------------------------------------------------------------

  Future<void> _loadRecentSearches() async {
    try {
      final SharedPreferences preferences =
      await SharedPreferences.getInstance();

      final List<String> stored =
          preferences.getStringList(_recentStorageKey) ??
              <String>[];

      if (!mounted) return;

      setState(() {
        _recentSearches = stored
            .where((item) => item.trim().isNotEmpty)
            .take(_maxRecentSearches)
            .toList();
      });
    } catch (error) {
      debugPrint(
        'MetaZone recent searches load failed: $error',
      );
    }
  }

  void _rememberSearch(String value) {
    final String term = value.trim();

    if (term.isEmpty) return;

    setState(() {
      _recentSearches.removeWhere(
            (item) => _normalize(item) == _normalize(term),
      );

      _recentSearches.insert(0, term);

      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches =
            _recentSearches.take(_maxRecentSearches).toList();
      }
    });

    unawaited(_persistRecentSearches());
  }

  void _removeRecentSearch(String value) {
    setState(() {
      _recentSearches.remove(value);
    });

    unawaited(_persistRecentSearches());
  }

  Future<void> _persistRecentSearches() async {
    try {
      final SharedPreferences preferences =
      await SharedPreferences.getInstance();

      await preferences.setStringList(
        _recentStorageKey,
        List<String>.from(_recentSearches),
      );
    } catch (error) {
      debugPrint(
        'MetaZone recent searches save failed: $error',
      );
    }
  }

  void _applySearchTerm(String value) {
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(
        offset: value.length,
      ),
    );

    _searchFocusNode.requestFocus();
  }

  // ------------------------------------------------------------
  // RESULT SELECTION
  // The selected result is returned to HomeScreen.
  // ------------------------------------------------------------

  void _selectEntry(_SearchEntry entry) {
    _rememberSearch(entry.title);

    switch (entry.kind) {
      case _SearchKind.place:
        final NearbyPlace? place = entry.place;

        if (place == null) return;

        Navigator.of(context).pop<SearchSelection>(
          SearchSelection(
            kind: SearchSelectionKind.place,
            place: place,
          ),
        );
        return;

      case _SearchKind.happening:
        final Happening? item = entry.happening;

        if (item == null) return;

        Navigator.of(context).pop<SearchSelection>(
          SearchSelection(
            kind: SearchSelectionKind.happening,
            happening: item,
          ),
        );
        return;

      case _SearchKind.action:
        final GoalAction? action = entry.action;

        if (action == null) return;

        Navigator.of(context).pop<SearchSelection>(
          SearchSelection(
            kind: SearchSelectionKind.action,
            action: action,
          ),
        );
        return;
    }
  }

  Future<void> _showSortOptions() async {
    final _SearchSort? selected =
    await showModalBottomSheet<_SearchSort>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort results',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _SortOptionTile(
                  title: 'Recommended',
                  subtitle: 'Keep the discovery order',
                  icon: Icons.auto_awesome_rounded,
                  selected: _sort == _SearchSort.recommended,
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      _SearchSort.recommended,
                    );
                  },
                ),
                _SortOptionTile(
                  title: 'Name: A to Z',
                  subtitle: 'Sort results alphabetically',
                  icon: Icons.sort_by_alpha_rounded,
                  selected: _sort == _SearchSort.alphabetical,
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      _SearchSort.alphabetical,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      _sort = selected;
    });
  }

  // ------------------------------------------------------------
  // SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildSearchInput(),
            const SizedBox(height: 14),
            _buildFilterBar(),
            const SizedBox(height: 10),
            Expanded(
              child: _buildResultsBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        12,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Explore near $_locationLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: IconButton(
              tooltip: 'Sort results',
              onPressed: _showSortOptions,
              icon: Icon(
                Icons.tune_rounded,
                color: AppColors.text,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.40),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 23,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) {
                  _rememberSearch(value);
                  FocusScope.of(context).unfocus();
                },
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Places, events, things to do...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  isCollapsed: true,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  _searchFocusNode.requestFocus();
                },
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: _SearchFilter.values.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final _SearchFilter filter =
          _SearchFilter.values[index];

          final String label = switch (filter) {
            _SearchFilter.all => 'All',
            _SearchFilter.places => 'Places',
            _SearchFilter.happenings => "What's on",
            _SearchFilter.actions => 'Actions',
          };

          final bool selected = _filter == filter;

          return ChoiceChip(
            label: Text(label),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _filter = filter;
              });
            },
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary.withValues(
              alpha: 0.22,
            ),
            side: BorderSide(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.07),
            ),
            labelStyle: TextStyle(
              color: selected
                  ? AppColors.text
                  : AppColors.textSecondary,
              fontSize: 12,
              fontWeight:
              selected ? FontWeight.w700 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsBody() {
    final List<_SearchEntry> results = _visibleResults;
    final bool hasQuery = _query.isNotEmpty;

    return ListView(
      key: ValueKey(
        '${_filter.name}_${_sort.name}_${_normalize(_query)}',
      ),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        28,
      ),
      children: [
        if (!hasQuery && _recentSearches.isNotEmpty) ...[
          _buildSectionHeader(
            'Recent searches',
            'Your latest searches',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((term) {
              return InputChip(
                avatar: Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                label: Text(
                  term,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => _applySearchTerm(term),
                onDeleted: () => _removeRecentSearch(term),
                backgroundColor: AppColors.surface,
                deleteIconColor: AppColors.textSecondary,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                labelStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (!hasQuery && _quickSearches.isNotEmpty) ...[
          _buildSectionHeader(
            'Quick explore',
            'Explore popular categories',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSearches.map((category) {
              return ActionChip(
                avatar: Icon(
                  Icons.explore_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(category),
                onPressed: () => _applySearchTerm(category),
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                labelStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        _buildSectionHeader(
          hasQuery ? 'Search results' : 'Discover near $_locationLabel',
          hasQuery
              ? '${results.length} result${results.length == 1 ? '' : 's'}'
              : 'Places, happenings and actions',
        ),
        const SizedBox(height: 12),
        if (results.isEmpty)
          _buildEmptyState()
        else
          ...results.map(
                (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SearchResultCard(
                entry: entry,
                onTap: () => _selectEntry(entry),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No matches found',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Try another name or choose a different category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();

              setState(() {
                _filter = _SearchFilter.all;
              });

              _searchFocusNode.requestFocus();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset search'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------
// SEARCH RESULT MODEL
// --------------------------------------------------------------

class _SearchEntry {
  const _SearchEntry({
    required this.title,
    required this.subtitle,
    required this.detailLabel,
    required this.trailingLabel,
    required this.kind,
    required this.icon,
    required this.searchText,
    this.place,
    this.happening,
    this.action,
  });

  final String title;
  final String subtitle;
  final String detailLabel;
  final String trailingLabel;
  final _SearchKind kind;
  final IconData icon;
  final String searchText;

  final NearbyPlace? place;
  final Happening? happening;
  final GoalAction? action;

  String get kindLabel {
    return switch (kind) {
      _SearchKind.place => 'PLACE',
      _SearchKind.happening => "WHAT'S ON",
      _SearchKind.action => 'ACTION',
    };
  }

  Color get accent {
    return switch (kind) {
      _SearchKind.place => const Color(0xFF9D7BFF),
      _SearchKind.happening => const Color(0xFF55D6D0),
      _SearchKind.action => const Color(0xFFFFB86C),
    };
  }
}

// --------------------------------------------------------------
// SEARCH RESULT CARD
// --------------------------------------------------------------

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.entry,
    required this.onTap,
  });

  final _SearchEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = entry.accent;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.065),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.27),
                      accent.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  entry.icon,
                  color: accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      entry.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            entry.kindLabel,
                            style: TextStyle(
                              color: accent,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.35,
                            ),
                          ),
                        ),
                        if (entry.detailLabel.trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              entry.detailLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (entry.trailingLabel.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              entry.trailingLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------
// SORT OPTION TILE
// --------------------------------------------------------------

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(
          icon,
          color: accent,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
      trailing: selected
          ? Icon(
        Icons.check_circle_rounded,
        color: accent,
      )
          : null,
      onTap: onTap,
    );
  }
}
