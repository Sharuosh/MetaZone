// lib/screens/home/modules/nearby_ar_screen.dart
// Nearby AR Screen — MetaZone (Upgraded)
// Drop-in replacement: tap opens ARSpotDetailsScreen (spot details)

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/theme.dart';
import '../../ar/spot_details/ar_spot_details_screen.dart'; // <<-- ensure path matches your project

// -----------------------------
// Data model
// -----------------------------
class NearbyARItem {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final String imageUrl;
  final String creatorName;
  final DateTime createdAt;
  final bool isPinned;

  NearbyARItem({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.creatorName,
    required this.createdAt,
    this.isPinned = false,
  });
}

// Mock sample dataset (used as fallback while Firestore isn't connected)
List<NearbyARItem> _mockNearbyItems = List.generate(14, (i) {
  final rng = Random();
  const cairoLat = 30.0444;
  const cairoLng = 31.2357;
  return NearbyARItem(
    id: 'ar_${i + 1}',
    title: 'AR Spot ${i + 1}',
    description:
    'A unique AR sticker placed here by creator ${rng.nextInt(40) + 1}. Explore it in MetaZone.',
    lat: cairoLat + (rng.nextDouble() - 0.5) * 0.02,
    lng: cairoLng + (rng.nextDouble() - 0.5) * 0.02,
    imageUrl: 'https://picsum.photos/seed/nearby$i/800/450',
    creatorName: 'Creator${rng.nextInt(50) + 1}',
    createdAt: DateTime.now().subtract(Duration(days: rng.nextInt(120))),
    isPinned: rng.nextBool() && i.isEven,
  );
});

// -----------------------------
// Nearby AR Screen
// -----------------------------
class NearbyARScreen extends StatefulWidget {
  const NearbyARScreen({Key? key}) : super(key: key);

  @override
  State<NearbyARScreen> createState() => _NearbyARScreenState();
}

class _NearbyARScreenState extends State<NearbyARScreen>
    with TickerProviderStateMixin {
  // Location state
  Position? _currentPosition;
  bool _loadingLocation = false;
  bool _permissionsGranted = false;

  // UI & filters
  String _searchQuery = '';
  RangeValues _distanceRange = const RangeValues(0, 10); // km
  List<String> _selectedTags = [];
  bool _showMap = false; // toggle between list and map
  bool _onlyPinned = false;

  // Data
  List<NearbyARItem> _displayedItems = [];

  // Controllers
  late TextEditingController _searchController;
  late AnimationController _fabController;
  final ScrollController _listScrollController = ScrollController();

  // Debug overlay
  bool _debugMode = false;

  // Staggered animation values
  late AnimationController _listAnimController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fabController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _listAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fabController.forward();
    _initPermissionsAndLocation();
    // initially show mock data until location is fetched
    _displayedItems = List.from(_mockNearbyItems);
    // start list animation
    Timer(const Duration(milliseconds: 150), () => _listAnimController.forward());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    _listScrollController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  Future<void> _initPermissionsAndLocation() async {
    setState(() => _loadingLocation = true);

    final status = await Permission.location.request();
    if (status.isGranted) {
      _permissionsGranted = true;
      try {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        setState(() {
          _currentPosition = pos;
        });
      } catch (e) {
        debugPrint('Geolocator error: $e');
        _currentPosition = null;
      }
    } else {
      _permissionsGranted = false;
    }

    setState(() => _loadingLocation = false);
    _applyFilters();
  }

  void _applyFilters() {
    List<NearbyARItem> list = List.from(_mockNearbyItems);

    // Search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((it) =>
      it.title.toLowerCase().contains(q) ||
          it.description.toLowerCase().contains(q) ||
          it.creatorName.toLowerCase().contains(q))
          .toList();
    }

    // Pinned
    if (_onlyPinned) {
      list = list.where((it) => it.isPinned).toList();
    }

    // Tags placeholder
    if (_selectedTags.isNotEmpty) {
      list = list
          .where((it) =>
          _selectedTags.any((tag) => it.description.toLowerCase().contains(tag)))
          .toList();
    }

    // Distance filter only if we have position
    if (_currentPosition != null) {
      final maxKm = _distanceRange.end;
      list = list.where((it) {
        final d = _distanceBetween(
            _currentPosition!.latitude, _currentPosition!.longitude, it.lat, it.lng);
        return d <= maxKm;
      }).toList();
    }

    // Sort pinned first, then by recency
    list.sort((a, b) {
      final pin = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
      if (pin != 0) return pin;
      return b.createdAt.compareTo(a.createdAt);
    });

    setState(() {
      _displayedItems = list;
    });
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Navigation -> open Spot Details (NEW behavior)
  void _openSpotDetails(NearbyARItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ARSpotDetailsScreen(spotId: item.id),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _openCreateSpot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: _CreateEditSpotSheet(onSave: (newItem) {
              setState(() {
                _mockNearbyItems.insert(0, newItem);
                _applyFilters();
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('AR Spot created (local demo)')));
            })),
      ),
    );
  }

  void _openEditSpot(NearbyARItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: _CreateEditSpotSheet(editItem: item, onSave: (saved) {
              setState(() {
                final idx = _mockNearbyItems.indexWhere((e) => e.id == saved.id);
                if (idx != -1) {
                  _mockNearbyItems[idx] = saved;
                }
                _applyFilters();
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('AR Spot saved (local demo)')));
            })),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search spots, creators, tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _applyFilters();
                  },
                  icon: const Icon(Icons.close),
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (v) {
                _searchQuery = v;
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              await _initPermissionsAndLocation();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Location refreshed')));
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final tags = ['art', 'graffiti', 'sculpt', 'game', 'history'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance (km)', style: Theme.of(context).textTheme.bodySmall),
                      RangeSlider(
                        values: _distanceRange,
                        min: 0,
                        max: 500,
                        divisions: 50,
                        labels: RangeLabels(_distanceRange.start.toStringAsFixed(0),
                            _distanceRange.end.toStringAsFixed(0)),
                        onChanged: (v) {
                          setState(() {
                            _distanceRange = v;
                          });
                          _applyFilters();
                        },
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  tooltip: _onlyPinned ? 'Show all' : 'Show pinned only',
                  onPressed: () => setState(() {
                    _onlyPinned = !_onlyPinned;
                    _applyFilters();
                  }),
                  icon: Icon(_onlyPinned ? Icons.push_pin : Icons.push_pin_outlined),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemBuilder: (_, i) {
                final tag = tags[i];
                final selected = _selectedTags.contains(tag);
                return ChoiceChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (s) {
                    setState(() {
                      if (s) _selectedTags.add(tag);
                      else _selectedTags.remove(tag);
                    });
                    _applyFilters();
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: tags.length,
            ),
          )
        ],
      ),
    );
  }

  Widget _listItem(NearbyARItem item, int idx) {
    final distance = _currentPosition != null
        ? _distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, item.lat, item.lng)
        : null;

    // stagger animation based on index
    final begin = (idx % 6) * 0.05;
    final animation = CurvedAnimation(
      parent: _listAnimController,
      curve: Interval(begin, (begin + 0.6).clamp(0.0, 1.0), curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
        child: MetaZoneCard(
          item: item,
          distanceKm: distance,
          onTap: () => _openSpotDetails(item),
          onEdit: () => _openEditSpot(item),
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_loadingLocation) return const Center(child: CircularProgressIndicator());

    if (!_permissionsGranted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 72, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('Location permission required', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Open app settings and allow location to find nearby AR spots.',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Open app settings'),
            )
          ],
        ),
      );
    }

    if (_displayedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 8),
            Text('No nearby AR spots found', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await _initPermissionsAndLocation();
                _applyFilters();
              },
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _listScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _displayedItems.length,
      itemBuilder: (ctx, idx) {
        final item = _displayedItems[idx];
        return _listItem(item, idx);
      },
    );
  }

  Widget _buildMapView() {
    // Placeholder view — replace with Google Maps or Mapbox integration
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map_outlined, size: 84, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Map view placeholder — configure Google Maps SDK to enable.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configure Google Maps in pubspec & Android/iOS manifests')));
            },
            child: const Text('Configure Map SDK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby AR', style: theme.textTheme.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _showMap ? 'Show list' : 'Show map',
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          IconButton(
            icon: Icon(_debugMode ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () => setState(() => _debugMode = !_debugMode),
            tooltip: 'Debug',
          )
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)),
        child: FloatingActionButton.extended(
          onPressed: _openCreateSpot,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add AR Spot'),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _initPermissionsAndLocation();
            _applyFilters();
          },
          child: Column(
            children: [
              _buildTopBar(),
              _buildFilters(),
              Expanded(child: _showMap ? _buildMapView() : _buildListView()),
              if (_debugMode) _buildDebugOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEBUG', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text('Permissions: ${_permissionsGranted ? 'granted' : 'denied'}', style: const TextStyle(color: Colors.white)),
          Text('Loading: ${_loadingLocation ? 'yes' : 'no'}', style: const TextStyle(color: Colors.white)),
          Text('Current position: ${_currentPosition?.latitude ?? '-'} , ${_currentPosition?.longitude ?? '-'}', style: const TextStyle(color: Colors.white)),
          Text('Displayed items: ${_displayedItems.length}', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

// -----------------------------
// Small Helper Widgets (embedded to keep file drop-in friendly)
// -----------------------------

class MetaZoneCard extends StatelessWidget {
  final NearbyARItem item;
  final double? distanceKm;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const MetaZoneCard({
    Key? key,
    required this.item,
    this.distanceKm,
    required this.onTap,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // hero tag for smooth image transition into details
    final heroTag = 'spot_image_${item.id}';
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AppColors.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:Image.network(
                    item.imageUrl,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.title, style: AppTextStyles.title(size: 16))),
                        if (item.isPinned) const Icon(Icons.push_pin, color: Colors.orange, size: 18)
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption()),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Text(
                          distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km' : '—',
                          style: AppTextStyles.body(size: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Text(_timeAgo(item.createdAt), style: AppTextStyles.caption()),
                        const Spacer(),
                        IconButton(onPressed: onEdit, icon: const Icon(Icons.more_vert_outlined)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }
}

// -----------------------------
// Create / Edit spot sheet (kept as in original but slightly styled)
// -----------------------------
class _CreateEditSpotSheet extends StatefulWidget {
  final NearbyARItem? editItem;
  final void Function(NearbyARItem) onSave;
  const _CreateEditSpotSheet({Key? key, this.editItem, required this.onSave}) : super(key: key);

  @override
  State<_CreateEditSpotSheet> createState() => _CreateEditSpotSheetState();
}

class _CreateEditSpotSheetState extends State<_CreateEditSpotSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleC;
  late TextEditingController _descC;
  late TextEditingController _imageC;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.editItem?.title ?? '');
    _descC = TextEditingController(text: widget.editItem?.description ?? '');
    _imageC = TextEditingController(text: widget.editItem?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _imageC.dispose();
    super.dispose();
  }

  Future<Position?> _captureCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return pos;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to capture location')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 12),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(widget.editItem == null ? 'Create AR Spot' : 'Edit AR Spot', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _titleC, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => (v == null || v.isEmpty) ? 'Title required' : null),
                  const SizedBox(height: 10),
                  TextFormField(controller: _descC, maxLines: 4, decoration: const InputDecoration(labelText: 'Description'), validator: (v) => (v == null || v.isEmpty) ? 'Description required' : null),
                  const SizedBox(height: 10),
                  TextFormField(controller: _imageC, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ElevatedButton.icon(onPressed: () async { final pos = await _captureCurrentLocation(); if (pos != null) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location captured'))); }, icon: const Icon(Icons.my_location), label: const Text('Use current location'))),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker not implemented in demo'))); }, icon: const Icon(Icons.image_outlined), label: const Text('Upload image'))
                  ]),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _saving = true);
                      await Future.delayed(const Duration(milliseconds: 700));
                      final pos = await _captureCurrentLocation();
                      final newItem = NearbyARItem(
                        id: widget.editItem?.id ?? 'ar_${DateTime.now().millisecondsSinceEpoch}',
                        title: _titleC.text.trim(),
                        description: _descC.text.trim(),
                        lat: pos?.latitude ?? 30.0444,
                        lng: pos?.longitude ?? 31.2357,
                        imageUrl: _imageC.text.isNotEmpty ? _imageC.text : 'https://picsum.photos/seed/new/800/450',
                        creatorName: 'me',
                        createdAt: DateTime.now(),
                        isPinned: false,
                      );
                      widget.onSave(newItem);
                      setState(() => _saving = false);
                      Navigator.of(context).pop();
                    },
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(widget.editItem == null ? 'Create Spot' : 'Save changes')),
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// =========================
// End of file
// -------------------------
// Integration checklist (copy to your project notes):
// 1. pubspec.yaml dependencies used in this file:
//    permission_handler: ^12.0.1
//    geolocator: ^14.0.2 (or compatible) — ensure platform settings for Android/iOS
//    cached_network_image: ^3.2.3
//    shimmer: ^2.0.0
//    google_maps_flutter: ^2.x.x (optional for Map view)
//    unity_widget: (if using Unity integration)
//    cloud_firestore: (for backend integration)
// 2. AndroidManifest.xml additions for location permissions and metadata (see code TODOs)
// 3. To wire Firestore: replace _mockNearbyItems with StreamBuilder reading collection 'nearby_spots'
// 4. To wire AR: open ARSpotDetailsScreen -> user presses "Enter AR" there to launch UnityWidget / ARView
// 5. Test on a real device (emulator might not provide location reliably)
// 6. Consider moving heavy image loading to pagination for production
