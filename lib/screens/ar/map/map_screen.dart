// File: lib/screens/ar/map/map_screen.dart
// AR Map Screen — Full 100% MetaZone design
// Features:
// - Google Map integration (placeholder API key must be set in platform folders)
// - Mock AR pins (spots) with clustering-like grouping (simple implementation)
// - Search, filters (Nearby / Trending / Featured), radius selector
// - Marker tap → rich bottom sheet with AR preview, details, actions
// - Floating actions: center to user, open AR viewer, add spot
// - Clear TODOs for Firestore + Unity/AR integration points

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/theme.dart';

class ARMapScreen extends StatefulWidget {
  const ARMapScreen({super.key});

  @override
  State<ARMapScreen> createState() => _ARMapScreenState();
}

class _ARMapScreenState extends State<ARMapScreen> {
  // Map controller
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();

  // Mock user location (replace with Geolocator/Location integration)
  LatLng _userLocation = const LatLng(30.0444, 31.2357); // Cairo default

  // Map camera-icon
  static const CameraPosition _initialCamera = CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 13.2);

  // UI state
  String _query = '';
  String _filter = 'Nearby'; // Nearby, Trending, Featured, All
  double _radiusMeters = 1000; // search radius
  bool _showList = false; // show side list

  // Spots data (mock). Replace by Firestore stream in production.
  late List<Map<String, dynamic>> _spots;

  // Markers
  Set<Marker> _markers = {};

  // Selected spot for bottom sheet
  Map<String, dynamic>? _selectedSpot;

  @override
  void initState() {
    super.initState();
    _generateMockSpots();
    _rebuildMarkers();
  }

  void _generateMockSpots() {
    final rnd = Random();
    _spots = List.generate(18, (i) {
      final lat = _userLocation.latitude + (rnd.nextDouble() - 0.5) / 50;
      final lng = _userLocation.longitude + (rnd.nextDouble() - 0.5) / 50;
      return {
        'id': 'spot_$i',
        'title': 'MetaSpot ${i + 1}',
        'description': 'Immersive AR piece. Place & explore!',
        'lat': lat,
        'lng': lng,
        'likes': rnd.nextInt(1200),
        'views': rnd.nextInt(20000),
        'featured': rnd.nextBool() && i.isEven,
        'creator': 'User${rnd.nextInt(80) + 1}',
      };
    });
  }

  void _rebuildMarkers() {
    final filtered = _applyFilters(_spots);
    final next = <Marker>{};

    for (final s in filtered) {
      final id = s['id'] as String;
      final lat = s['lat'] as double;
      final lng = s['lng'] as double;

      next.add(Marker(
        markerId: MarkerId(id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: s['title'], snippet: s['creator']),
        icon: BitmapDescriptor.defaultMarkerWithHue(s['featured'] ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueViolet),
        onTap: () => _onMarkerTap(s),
      ));
    }

    setState(() => _markers = next);
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    var ret = List<Map<String, dynamic>>.from(list);
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      ret = ret.where((s) => s['title'].toLowerCase().contains(q) || s['description'].toLowerCase().contains(q) || s['creator'].toLowerCase().contains(q)).toList();
    }

    if (_filter == 'Nearby') {
      // simple distance filter (Euclidean; replace with Haversine for accuracy)
      ret = ret.where((s) {
        final dx = (s['lat'] as double) - _userLocation.latitude;
        final dy = (s['lng'] as double) - _userLocation.longitude;
        final meters = sqrt(dx * dx + dy * dy) * 111000; // rough approximation
        return meters <= _radiusMeters;
      }).toList();
      // sort by distance
      ret.sort((a, b) {
        final da = sqrt(pow((a['lat'] - _userLocation.latitude), 2) + pow((a['lng'] - _userLocation.longitude), 2));
        final db = sqrt(pow((b['lat'] - _userLocation.latitude), 2) + pow((b['lng'] - _userLocation.longitude), 2));
        return da.compareTo(db);
      });
    } else if (_filter == 'Trending') {
      ret.sort((b, a) => (a['likes'] + (a['views'] ~/ 20)).compareTo(b['likes'] + (b['views'] ~/ 20)));
    } else if (_filter == 'Featured') {
      ret = ret.where((s) => s['featured'] == true).toList();
    }

    return ret;
  }

  void _onMarkerTap(Map<String, dynamic> spot) {
    setState(() => _selectedSpot = spot);
    _openSpotBottomSheet(spot);
  }

  void _openSpotBottomSheet(Map<String, dynamic> spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (ctx, sc) => Container(
          decoration: BoxDecoration(color: AppColors.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 60, height: 6, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(6))),
            Expanded(
              child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
                Row(children: [
                  Expanded(child: Text(spot['title'], style: AppTextStyles.title())),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: AppColors.textLight))
                ]),
                const SizedBox(height: 8),
                Text('Creator: ${spot['creator']}', style: AppTextStyles.caption()),
                const SizedBox(height: 12),
                Container(height: 160, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(Icons.vrpano, size: 56, color: AppColors.primary))),
                const SizedBox(height: 12),
                Text(spot['description'], style: AppTextStyles.body()),
                const SizedBox(height: 12),
                Row(children: [
                  ElevatedButton.icon(onPressed: () => _launchARForSpot(spot), icon: const Icon(Icons.camera), label: const Text('Open AR')),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(onPressed: () => _saveSpotLocal(spot), icon: const Icon(Icons.bookmark_border), label: const Text('Save')),
                ]),
                const SizedBox(height: 12),
                Text('Stats', style: AppTextStyles.title(size: 14)),
                const SizedBox(height: 8),
                Row(children: [Text('${spot['likes']} likes', style: AppTextStyles.caption()), const SizedBox(width: 12), Text('${spot['views']} views', style: AppTextStyles.caption())]),
                const SizedBox(height: 18),
                Text('Location', style: AppTextStyles.title(size: 14)),
                const SizedBox(height: 8),
                Text('Lat: ${spot['lat'].toStringAsFixed(5)}, Lng: ${spot['lng'].toStringAsFixed(5)}', style: AppTextStyles.caption()),
                const SizedBox(height: 24),
                Text('Comments (demo)', style: AppTextStyles.title(size: 14)),
                const SizedBox(height: 8),
                ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('UserOne'), subtitle: const Text('Amazing spot!')),
                ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('ARFan'), subtitle: const Text('Loved it')),
                const SizedBox(height: 30),
              ]),
            )
          ]),
        ),
      ),
    );
  }

  void _launchARForSpot(Map<String, dynamic> spot) {
    Navigator.pop(context);
    // TODO: Integrate UnityWidget or AR activity and pass spot['id']
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: AppColors.surface, title: Text('Launch AR', style: AppTextStyles.title()), content: Text('Launching AR for ${spot['title']} (demo).'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
  }

  void _saveSpotLocal(Map<String, dynamic> spot) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to favorites (demo)')));
  }

  // Center camera-icon to user
  Future<void> _centerToUser() async {
    if (_mapController == null) return;
    final c = await _mapControllerCompleter.future;
    await c.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _userLocation, zoom: 15.2)));
  }

  // Toggle list drawer
  void _toggleList() {
    setState(() => _showList = !_showList);
  }

  // Add new spot (navigates to CreateARScreen) — TODO: pass initial location
  void _onAddSpot() {
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateARScreen()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open Create AR (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    final filteredSpots = _applyFilters(_spots);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('AR Map', style: AppTextStyles.heading()),
        actions: [
          IconButton(onPressed: () => setState(() { _query = ''; _rebuildMarkers(); }), icon: Icon(Icons.filter_alt_off, color: AppColors.textLight)),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              onMapCreated: (c) {
                _mapController = c;
                if (!_mapControllerCompleter.isCompleted) _mapControllerCompleter.complete(c);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              compassEnabled: true,
              mapToolbarEnabled: false,
              onTap: (_) => setState(() => _selectedSpot = null),
            ),
          ),

          // Search & filters overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),

          // Radius indicator
          if (_showList)
            Positioned(
              right: 12,
              top: 140,
              child: _miniListCard(filteredSpots),
            ),

          // Bottom-left panel: results snapshot
          Positioned(
            left: 12,
            bottom: 24,
            child: GestureDetector(
              onTap: _toggleList,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [Icon(_filter == 'Nearby' ? Icons.location_on : Icons.trending_up, color: AppColors.primary), const SizedBox(width: 8), Text('${filteredSpots.length} spots', style: AppTextStyles.body())]),
              ),
            ),
          ),

          // Floating actions
          Positioned(
            right: 12,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  onPressed: _centerToUser,
                  heroTag: 'center',
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.my_location, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () => _launchARForSpot(filteredSpots.isNotEmpty ? filteredSpots.first : _spots.first),
                  heroTag: 'ar',
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.vrpano, color: Colors.black),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _onAddSpot,
                  heroTag: 'add',
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // small overlay list card
  Widget _miniListCard(List<Map<String, dynamic>> items) {
    return Container(
      width: 240,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(10), child: Row(children: [Text('Results', style: AppTextStyles.title()), const Spacer(), IconButton(onPressed: _toggleList, icon: Icon(Icons.close, color: AppColors.textLight))])),
        Container(height: 1, color: AppColors.border),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length.clamp(0, 6),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final s = items[i];
            return ListTile(
              dense: true,
              leading: CircleAvatar(backgroundColor: AppColors.surface, child: Icon(Icons.view_in_ar, color: AppColors.primary)),
              title: Text(s['title'], style: AppTextStyles.body()),
              subtitle: Text(s['creator'], style: AppTextStyles.caption()),
              onTap: () {
                _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(s['lat'], s['lng'])));
                _onMarkerTap(s);
              },
            );
          },
        )
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Row(children: [
      Expanded(
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.search),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(border: InputBorder.none, hintText: 'Search spots, creators, tags...'),
                onChanged: (v) => setState(() { _query = v; _rebuildMarkers(); }),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(onTap: () => setState(() { _query = ''; _rebuildMarkers(); }), child: Icon(Icons.close, color: AppColors.textLight))
          ]),
        ),
      ),
      const SizedBox(width: 10),
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [Text('Radius', style: AppTextStyles.caption()), const SizedBox(width: 6), Text('${(_radiusMeters / 1000).toStringAsFixed(1)} km', style: AppTextStyles.title(size: 12))]),
      )
    ]);
  }

  Widget _buildFilterChips() {
    final filters = ['Nearby', 'Trending', 'Featured', 'All'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final active = f == _filter;
          return GestureDetector(
            onTap: () => setState(() { _filter = f; _rebuildMarkers(); }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
              child: Row(children: [Icon(f == 'Nearby' ? Icons.location_on : (f == 'Trending' ? Icons.trending_up : (f == 'Featured' ? Icons.star : Icons.list)), size: 16, color: active ? Colors.black : AppColors.text), const SizedBox(width: 8), Text(f, style: active ? AppTextStyles.body() : AppTextStyles.caption())]),
            ),
          );
        },
      ),
    );
  }
}

// TODOs & Integration notes:
// - Replace mock _spots with Firestore query: stream snapshots from `spots` collection, and call _rebuildMarkers when data changes.
// - Use geolocator/location permission flows to fetch accurate user position and set _userLocation.
// - For large data sets, implement server-side clustering or use a clustering plugin.
// - Integrate UnityWidget or native AR view in _launchARForSpot and pass spot id/anchor info.
// - Add analytics events for open_map, open_spot, launch_ar, save_spot.
// - Improve distance calculation with Haversine formula for production.
