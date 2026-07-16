// ======================================================
// Explore Screen — MetaZone (Upgraded & Connected to Spot Details)
// ======================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/theme.dart';
import '../../ar/spot_details/ar_spot_details_screen.dart';


// ---------------------------------------------------------------------
// DATA MODEL
// ---------------------------------------------------------------------
class ExploreSpot {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final double lat;
  final double lng;
  final String imageUrl;
  final bool featured;
  final int likes;
  final DateTime createdAt;

  ExploreSpot({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.featured,
    required this.likes,
    required this.createdAt,
  });
}

// ----------------------------------------------
// MOCK DATA (Placeholder)
// ----------------------------------------------
final List<ExploreSpot> _mockSpots = List.generate(12, (i) {
  final rng = Random();
  const baseLat = 30.0444;
  const baseLng = 31.2357;

  return ExploreSpot(
    id: "spot_$i",
    title: [
      "Nebula Gate",
      "HoloBench",
      "Neon Fox",
      "Halo Orb",
      "Sky Lantern",
      "Mini Dino",
      "AR Mural",
      "Portal Pet",
      "Sky Dome",
      "Lumen Tree",
      "Echo Box",
      "Mirror Cube"
    ][i % 12],
    subtitle: "Creator ${rng.nextInt(50)}",
    description: "AR content waiting to be explored.",
    lat: baseLat + (rng.nextDouble() - 0.5) * 0.04,
    lng: baseLng + (rng.nextDouble() - 0.5) * 0.04,
    imageUrl: "https://picsum.photos/seed/explore$i/800/500",
    featured: rng.nextBool(),
    likes: rng.nextInt(2000),
    createdAt: DateTime.now().subtract(Duration(days: rng.nextInt(200))),
  );
});

// ===============================================================
// EXPLORE SCREEN
// ===============================================================
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  Position? _position;
  bool _loadingLocation = false;
  bool _permissionGranted = false;

  String _search = "";
  String _sortBy = "Recommended";
  bool _showFeatured = false;

  List<ExploreSpot> _spots = [];
  List<ExploreSpot> _filtered = [];

  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _spots = List.from(_mockSpots);
    _fabAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
    _initLocation();
    _applyFilters();
  }

  // -------------------------------------------------------
  // LOCATION
  // -------------------------------------------------------
  Future<void> _initLocation() async {
    setState(() => _loadingLocation = true);

    final status = await Permission.location.request();
    if (!mounted) return;

    _permissionGranted = status.isGranted;

    if (_permissionGranted) {
      try {
        _position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      } catch (_) {}
    }

    setState(() => _loadingLocation = false);
    _applyFilters();
  }

  // -------------------------------------------------------
  // FILTERS
  // -------------------------------------------------------
  void _applyFilters() {
    var list = List<ExploreSpot>.from(_spots);

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((s) =>
      s.title.toLowerCase().contains(q) ||
          s.subtitle.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q)).toList();
    }

    if (_showFeatured) list = list.where((s) => s.featured).toList();

    if (_position != null) {
      list.sort((a, b) {
        final da = _distance(a.lat, a.lng);
        final db = _distance(b.lat, b.lng);

        if (_sortBy == "Distance") return da.compareTo(db);
        if (_sortBy == "Popular") return b.likes.compareTo(a.likes);
        if (_sortBy == "New") return b.createdAt.compareTo(a.createdAt);

        return (b.likes - db.round()).compareTo(a.likes - da.round());
      });
    }

    setState(() => _filtered = list);
  }

  double _distance(double lat, double lng) {
    const R = 6371;
    final dLat = (lat - _position!.latitude) * (pi / 180);
    final dLng = (lng - _position!.longitude) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_position!.latitude * pi / 180) *
            cos(lat * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // =====================================================
  // BUILD UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildFallbackMap()),
            Positioned(left: 16, top: 14, child: _buildHeader()),
            _buildBottomList(),
            Positioned(right: 16, bottom: 26, child: _buildFAB()),
          ],
        ),
      ),
    );
  }

  // ---------------- MAP (Fallback Glow) ----------------
  Widget _buildFallbackMap() {
    return CustomPaint(
      painter: _ExploreGlowPainter(),
      child: Container(),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Explore",
            style: GoogleFonts.orbitron(
                color: AppColors.primary, fontSize: 28)),
        const SizedBox(height: 6),
        Text("Find AR spots around you",
            style: TextStyle(color: AppColors.textLight)),
      ],
    );
  }

  // ---------------- FAB ----------------
  Widget _buildFAB() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
      child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_location_alt_outlined,
              color: Colors.black),
          onPressed: () {}),
    );
  }

  // ---------------- LIST SHEET ----------------
  Widget _buildBottomList() {
    return DraggableScrollableSheet(
      initialChildSize: .38,
      minChildSize: .25,
      maxChildSize: .92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 14),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildChips(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _filtered.length,
                padding: const EdgeInsets.only(bottom: 18),
                itemBuilder: (_, i) => _buildSpotCard(_filtered[i]),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- SEARCH ----------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search spots...",
          hintStyle: TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          fillColor: AppColors.card,
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
        onChanged: (v) {
          _search = v;
          _applyFilters();
        },
      ),
    );
  }

  // ---------------- CHIPS ----------------
  Widget _buildChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text("Featured"),
            selected: _showFeatured,
            onSelected: (b) {
              setState(() => _showFeatured = b);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10)),
            child: Text("${_filtered.length} spots"),
          )
        ],
      ),
    );
  }

  // ---------------- SPOT CARD ----------------
  Widget _buildSpotCard(ExploreSpot s) {
    final dist = _position != null ? _distance(s.lat, s.lng) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ARSpotDetailsScreen(spotId: s.id)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14)),
                child: Image.network(
                  s.imageUrl,
                  width: 110,
                  height: 80,
                  fit: BoxFit.cover,
                )
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(s.title,
                                    style: AppTextStyles.title())),
                            if (s.featured)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Text("Featured",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(s.subtitle, style: AppTextStyles.caption()),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                                dist == null
                                    ? "—"
                                    : "${dist.toStringAsFixed(1)} km",
                                style: AppTextStyles.caption()),
                            const SizedBox(width: 10),
                            const Icon(Icons.favorite,
                                size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text("${s.likes}",
                                style: AppTextStyles.caption()),
                          ],
                        )
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// Fallback Painter (glowing nebula map)
// ===============================================================
class _ExploreGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;

    final gradient = RadialGradient(
      center: const Alignment(-0.2, -0.6),
      radius: 1.4,
      colors: [
        AppColors.background,
        Colors.deepPurple.shade900.withOpacity(.8),
        AppColors.background,
      ],
      stops: const [0, .6, 1],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final paint = Paint()..color = Colors.white.withOpacity(.04);
    final rng = Random();

    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * s.width;
      final y = rng.nextDouble() * s.height * .7;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 70 + 8, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
