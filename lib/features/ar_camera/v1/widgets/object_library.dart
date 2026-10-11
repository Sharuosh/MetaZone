import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';

/// MetaZone Object Library.
///
/// Complete Flutter-side object browsing module.
///
/// Flow:
/// Create Wheel
///      ↓
/// Object Library
///      ↓
/// Object Preview / Details
///      ↓
/// Object Customization
///      ↓
/// Object Placement
///
/// Responsibilities:
/// - Search
/// - Category filtering
/// - Featured objects
/// - All objects
/// - Selection state
/// - Press feedback
/// - Empty state
/// - Clear search
/// - Keyboard handling
/// - Responsive presentation
///
/// Unity / AR placement is intentionally outside this widget.
/// `onObjectSelected` is the integration point for the next
/// Flutter flow.
class ObjectLibrary extends StatefulWidget {
  const ObjectLibrary({
    super.key,
    required this.onClose,
    required this.onObjectSelected,
  });

  final VoidCallback onClose;
  final ValueChanged<ARLibraryObject> onObjectSelected;

  @override
  State<ObjectLibrary> createState() => _ObjectLibraryState();
}

class _ObjectLibraryState extends State<ObjectLibrary> {
  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  final ScrollController _scrollController =
  ScrollController();

  final GlobalKey _allObjectsKey = GlobalKey();

  String _selectedCategory = 'All';

  ARLibraryObject? _selectedObject;

  bool _isSearching = false;

  // ============================================================
  // DATA
  // ============================================================

  final List<ARLibraryObject> _objects = const [
    ARLibraryObject(
      id: 'tree',
      name: 'Tree',
      category: 'Nature',
      icon: Icons.park_rounded,
      description: 'A spatial tree for natural AR scenes.',
      featured: true,
    ),
    ARLibraryObject(
      id: 'plant',
      name: 'Plant',
      category: 'Nature',
      icon: Icons.local_florist_rounded,
      description: 'A small decorative plant.',
      featured: true,
    ),
    ARLibraryObject(
      id: 'chair',
      name: 'Chair',
      category: 'Furniture',
      icon: Icons.chair_rounded,
      description: 'A spatial furniture object.',
      featured: false,
    ),
    ARLibraryObject(
      id: 'lamp',
      name: 'Lamp',
      category: 'Furniture',
      icon: Icons.light_rounded,
      description: 'A decorative AR light object.',
      featured: true,
    ),
    ARLibraryObject(
      id: 'robot',
      name: 'Robot',
      category: 'Characters',
      icon: Icons.smart_toy_rounded,
      description: 'An interactive spatial character.',
      featured: true,
    ),
    ARLibraryObject(
      id: 'person',
      name: 'Person',
      category: 'Characters',
      icon: Icons.accessibility_new_rounded,
      description: 'A human-like spatial character.',
      featured: false,
    ),
    ARLibraryObject(
      id: 'car',
      name: 'Car',
      category: 'Vehicles',
      icon: Icons.directions_car_rounded,
      description: 'A vehicle for spatial scenes.',
      featured: true,
    ),
    ARLibraryObject(
      id: 'bike',
      name: 'Bike',
      category: 'Vehicles',
      icon: Icons.pedal_bike_rounded,
      description: 'A lightweight spatial vehicle.',
      featured: false,
    ),
    ARLibraryObject(
      id: 'statue',
      name: 'Statue',
      category: 'Art',
      icon: Icons.account_balance_rounded,
      description: 'A decorative AR art piece.',
      featured: true,
    ),
    ARLibraryObject(
      id: 'cube',
      name: 'Cube',
      category: 'Shapes',
      icon: Icons.view_in_ar_rounded,
      description: 'A simple spatial primitive.',
      featured: false,
    ),
    ARLibraryObject(
      id: 'star',
      name: 'Star',
      category: 'Effects',
      icon: Icons.star_rounded,
      description: 'A glowing decorative object.',
      featured: false,
    ),
    ARLibraryObject(
      id: 'portal',
      name: 'Portal',
      category: 'Special',
      icon: Icons.blur_on_rounded,
      description: 'A gateway into another AR experience.',
      featured: true,
    ),
  ];


  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTERING
  // ============================================================

  String get _query =>
      _searchController.text.trim().toLowerCase();

  List<ARLibraryObject> get _filteredObjects {
    return _objects.where((object) {
      final matchesCategory =
          _selectedCategory == 'All' ||
              object.category == _selectedCategory;

      final matchesSearch =
          _query.isEmpty ||
              object.name.toLowerCase().contains(_query) ||
              object.category.toLowerCase().contains(_query) ||
              object.description.toLowerCase().contains(_query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ARLibraryObject> get _featuredObjects {
    return _objects.where((object) {
      final matchesCategory =
          _selectedCategory == 'All' ||
              object.category == _selectedCategory;

      final matchesSearch =
          _query.isEmpty ||
              object.name.toLowerCase().contains(_query) ||
              object.category.toLowerCase().contains(_query) ||
              object.description.toLowerCase().contains(_query);

      return object.featured &&
          matchesCategory &&
          matchesSearch;
    }).toList();
  }

  bool get _showFeatured =>
      _selectedCategory == 'All' &&
          _query.isEmpty &&
          _featuredObjects.isNotEmpty;

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.trim().isNotEmpty;
      _selectedObject = null;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _isSearching = false;
      _selectedObject = null;
    });

    _searchFocusNode.unfocus();
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();

    setState(() {
      _isSearching = true;
    });
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void _selectCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }

    setState(() {
      _selectedCategory = category;
      _selectedObject = null;
    });
  }

  // ============================================================
  // SEE ALL
  // ============================================================

  void _showAllObjects() {
    final context = _allObjectsKey.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: ARCameraTheme.motionSmooth,
        curve: ARCameraTheme.motionCurve,
        alignment: 0.05,
      );
    }
  }

  // ============================================================
  // OBJECT SELECTION
  // ============================================================

  void _selectObject(ARLibraryObject object) {
    if (_selectedObject?.id == object.id) {
      widget.onObjectSelected(object);
      return;
    }

    setState(() {
      _selectedObject = object;
    });

    // Selection state is intentionally visible for a short moment
    // before handing the object to the next Flutter flow.
    Future<void>.delayed(
      ARCameraTheme.motionFast,
          () {
        if (!mounted) {
          return;
        }

        if (_selectedObject?.id == object.id) {
          widget.onObjectSelected(object);
        }
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final objects = _filteredObjects;
    final featured = _featuredObjects;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            12,
            10,
            12,
            12,
          ),
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              _LibraryHeader(
                searching: _isSearching,
                onClose: widget.onClose,
                onSearchFocus: _focusSearch,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // SEARCH
              // ==================================================

              _SearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CATEGORIES
              // ==================================================

              _CategoryBar(
                selected: _selectedCategory,
                onSelected: _selectCategory,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child: objects.isEmpty
                    ? _EmptyLibrary(
                  hasSearch: _query.isNotEmpty,
                  onClear: _query.isNotEmpty
                      ? _clearSearch
                      : null,
                )
                    : CustomScrollView(
                  controller: _scrollController,
                  physics:
                  const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
                  slivers: [
                    // --------------------------------------
                    // FEATURED
                    // --------------------------------------

                    if (_showFeatured) ...[
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Featured',
                          action: 'See all',
                          onTap: _showAllObjects,
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 10),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 146,
                          child: ListView.separated(
                            scrollDirection:
                            Axis.horizontal,
                            physics:
                            const BouncingScrollPhysics(),
                            itemCount:
                            featured.length,
                            separatorBuilder:
                                (_, __) =>
                            const SizedBox(
                              width: 10,
                            ),
                            itemBuilder:
                                (context, index) {
                              final object =
                              featured[index];

                              return _FeaturedObjectCard(
                                object: object,
                                selected:
                                _selectedObject?.id ==
                                    object.id,
                                onTap: () =>
                                    _selectObject(
                                      object,
                                    ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 18),
                      ),
                    ],

                    // --------------------------------------
                    // ALL OBJECTS
                    // --------------------------------------

                    SliverToBoxAdapter(
                      child: Container(
                        key: _allObjectsKey,
                        child: _SectionHeader(
                          title: _showFeatured
                              ? 'All Objects'
                              : '${objects.length} Objects',
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 10),
                    ),

                    // --------------------------------------
                    // GRID
                    // --------------------------------------

                    SliverGrid(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {
                          final object =
                          objects[index];

                          return _ObjectCard(
                            object: object,
                            selected:
                            _selectedObject?.id ==
                                object.id,
                            onTap: () =>
                                _selectObject(object),
                          );
                        },
                        childCount: objects.length,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.92,
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// DATA
// ==================================================================

class ARLibraryObject {
  const ARLibraryObject({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
    required this.featured,
  });

  final String id;
  final String name;
  final String category;
  final IconData icon;
  final String description;
  final bool featured;
}

// ==================================================================
// HEADER
// ==================================================================

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.searching,
    required this.onClose,
    required this.onSearchFocus,
  });

  final bool searching;
  final VoidCallback onClose;
  final VoidCallback onSearchFocus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderButton(
          icon: Icons.arrow_back_rounded,
          semanticLabel: 'Close Object Library',
          onTap: onClose,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Object Library',
                style: TextStyle(
                  color: ARCameraTheme.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                searching
                    ? 'Searching your AR objects'
                    : 'Choose something to place in your world',
                style: const TextStyle(
                  color: ARCameraTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _HeaderButton(
          icon: Icons.search_rounded,
          semanticLabel: 'Search Objects',
          onTap: onSearchFocus,
        ),
      ],
    );
  }
}

// ==================================================================
// HEADER BUTTON
// ==================================================================

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ARCameraTheme.glassSoftColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: ARCameraTheme.border,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: ARCameraTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SEARCH
// ==================================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: ARGlass(
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
        blur: ARCameraTheme.glassBlur,
        opacity: ARCameraTheme.glassOpacity,
        child: SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              color: ARCameraTheme.textPrimary,
              fontSize: 12,
            ),
            cursorColor:
            ARCameraTheme.primaryBright,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search objects...',
              hintStyle: const TextStyle(
                color: ARCameraTheme.textMuted,
                fontSize: 11,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color:
                ARCameraTheme.textSecondary,
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color:
                  ARCameraTheme.textSecondary,
                ),
              ),
              contentPadding:
              const EdgeInsets.symmetric(
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CATEGORY BAR
// ==================================================================

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const categories = [
    'All',
    'Nature',
    'Furniture',
    'Characters',
    'Vehicles',
    'Art',
    'Shapes',
    'Effects',
    'Special',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
        const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 7),
        itemBuilder: (_, index) {
          final category =
          categories[index];

          final active =
              category == selected;

          return Semantics(
            button: true,
            selected: active,
            label: '$category category',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    onSelected(category),
                borderRadius:
                BorderRadius.circular(11),
                child: AnimatedContainer(
                  duration:
                  ARCameraTheme.motionFast,
                  curve:
                  ARCameraTheme.motionCurve,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? ARCameraTheme.primary
                        : ARCameraTheme.glassSoftColor,
                    borderRadius:
                    BorderRadius.circular(11),
                    border: Border.all(
                      color: active
                          ? ARCameraTheme
                          .primaryBright
                          : ARCameraTheme.border,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : ARCameraTheme
                          .textSecondary,
                      fontSize: 9,
                      fontWeight: active
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// SECTION HEADER
// ==================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ARCameraTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (action != null)
          Semantics(
            button: true,
            label: action,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius:
                BorderRadius.circular(8),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Text(
                        action!,
                        style: const TextStyle(
                          color: ARCameraTheme
                              .primaryBright,
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 9,
                        color: ARCameraTheme
                            .primaryBright,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ==================================================================
// FEATURED CARD
// ==================================================================

class _FeaturedObjectCard extends StatefulWidget {
  const _FeaturedObjectCard({
    required this.object,
    required this.selected,
    required this.onTap,
  });

  final ARLibraryObject object;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_FeaturedObjectCard> createState() =>
      _FeaturedObjectCardState();
}

class _FeaturedObjectCardState
    extends State<_FeaturedObjectCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label:
      '${widget.object.name}, ${widget.object.category}',
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
        },
        onTapCancel: () {
          setState(() => _pressed = false);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration:
          ARCameraTheme.motionFast,
          child: AnimatedContainer(
            duration:
            ARCameraTheme.motionFast,
            width: 118,
            padding:
            const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: widget.selected
                  ? ARCameraTheme.primarySoft
                  : ARCameraTheme.glassColor,
              borderRadius:
              BorderRadius.circular(17),
              border: Border.all(
                color: widget.selected
                    ? ARCameraTheme
                    .borderActive
                    : ARCameraTheme.border,
                width:
                widget.selected ? 1.2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                      ARCameraTheme
                          .primarySoft,
                      borderRadius:
                      BorderRadius.circular(
                          12),
                    ),
                    child: Stack(
                      alignment:
                      Alignment.center,
                      children: [
                        Icon(
                          widget.object.icon,
                          size: 28,
                          color: ARCameraTheme
                              .primaryBright,
                        ),
                        if (widget.selected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child:
                            _SelectionBadge(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  widget.object.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                    ARCameraTheme.textPrimary,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.object.category,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                    ARCameraTheme.textMuted,
                    fontSize: 8,
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

// ==================================================================
// OBJECT CARD
// ==================================================================

class _ObjectCard extends StatefulWidget {
  const _ObjectCard({
    required this.object,
    required this.selected,
    required this.onTap,
  });

  final ARLibraryObject object;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ObjectCard> createState() =>
      _ObjectCardState();
}

class _ObjectCardState
    extends State<_ObjectCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label:
      '${widget.object.name}, ${widget.object.category}',
      child: GestureDetector(
        behavior:
        HitTestBehavior.opaque,
        onTapDown: (_) {
          setState(() => _pressed = true);
        },
        onTapCancel: () {
          setState(() => _pressed = false);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration:
          ARCameraTheme.motionFast,
          curve:
          ARCameraTheme.motionCurve,
          child: ARGlass(
            padding:
            const EdgeInsets.all(9),
            borderRadius:
            const BorderRadius.all(
              Radius.circular(17),
            ),
            blur:
            ARCameraTheme.glassBlur,
            opacity:
            widget.selected
                ? 0.58
                : ARCameraTheme
                .glassOpacity,
            child: AnimatedContainer(
              duration:
              ARCameraTheme.motionFast,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                    12),
                border: widget.selected
                    ? Border.all(
                  color: ARCameraTheme
                      .borderActive,
                  width: 1.1,
                )
                    : null,
              ),
              padding:
              widget.selected
                  ? const EdgeInsets.all(1)
                  : EdgeInsets.zero,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Expanded(
                    child: Container(
                      width:
                      double.infinity,
                      decoration:
                      BoxDecoration(
                        color: widget.selected
                            ? ARCameraTheme
                            .primarySoft
                            : ARCameraTheme
                            .glassSoftColor,
                        borderRadius:
                        BorderRadius
                            .circular(
                            13),
                        border: Border.all(
                          color:
                          ARCameraTheme
                              .border,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: AnimatedScale(
                              scale: widget
                                  .selected
                                  ? 1.06
                                  : 1,
                              duration:
                              ARCameraTheme
                                  .motionFast,
                              child: Icon(
                                widget.object
                                    .icon,
                                size: 34,
                                color: ARCameraTheme
                                    .primaryBright,
                              ),
                            ),
                          ),

                          // FEATURED
                          if (widget
                              .object.featured)
                            Positioned(
                              top: 6,
                              left: 6,
                              child:
                              _SmallTag(
                                label:
                                'Featured',
                              ),
                            ),

                          // SELECTION
                          if (widget.selected)
                            Positioned(
                              top: 6,
                              right: 6,
                              child:
                              _SelectionBadge(),
                            ),

                          // OPEN INDICATOR
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child:
                            _ArrowBadge(
                              selected:
                              widget.selected,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.object.name,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                      ARCameraTheme
                          .textPrimary,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.object.category,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                      ARCameraTheme
                          .textMuted,
                      fontSize: 8,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SMALL TAG
// ==================================================================

class _SmallTag extends StatelessWidget {
  const _SmallTag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color:
        ARCameraTheme.primarySoft,
        borderRadius:
        BorderRadius.circular(7),
        border: Border.all(
          color:
          ARCameraTheme.borderActive,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color:
          ARCameraTheme.primaryBright,
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ==================================================================
// SELECTION BADGE
// ==================================================================

class _SelectionBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
        ARCameraTheme.primary,
        border: Border.all(
          color:
          ARCameraTheme.primaryBright,
        ),
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}

// ==================================================================
// ARROW BADGE
// ==================================================================

class _ArrowBadge extends StatelessWidget {
  const _ArrowBadge({
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? ARCameraTheme.primary
            : ARCameraTheme
            .glassStrongColor,
        border: Border.all(
          color: selected
              ? ARCameraTheme
              .primaryBright
              : ARCameraTheme.border,
        ),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 12,
        color: selected
            ? Colors.white
            : ARCameraTheme.textPrimary,
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({
    required this.hasSearch,
    required this.onClear,
  });

  final bool hasSearch;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                ARCameraTheme
                    .glassSoftColor,
                border: Border.all(
                  color:
                  ARCameraTheme.border,
                ),
              ),
              child: Icon(
                hasSearch
                    ? Icons
                    .search_off_rounded
                    : Icons
                    .inventory_2_outlined,
                size: 24,
                color:
                ARCameraTheme
                    .textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch
                  ? 'No objects found'
                  : 'Nothing here yet',
              style: const TextStyle(
                color:
                ARCameraTheme
                    .textPrimary,
                fontSize: 14,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              hasSearch
                  ? 'Try another search or category.'
                  : 'Try another category.',
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                color:
                ARCameraTheme
                    .textMuted,
                fontSize: 10,
                height: 1.35,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 14,
                ),
                label: const Text(
                  'Clear Search',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  ARCameraTheme
                      .textSecondary,
                  side:
                  const BorderSide(
                    color:
                    ARCameraTheme
                        .border,
                  ),
                  minimumSize:
                  const Size(
                    0,
                    34,
                  ),
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 12,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}