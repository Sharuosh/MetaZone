// lib/screens/home/chat/ar_objects_chats.dart
// MetaZone — AR Objects Chats (Connected Edition 100%)

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import '../../../services/ar_object_chat_service.dart';
import '../../ar/object_details/ar_object_details_screen.dart';
import '../../../core/theme/theme.dart';
import 'chat_screen.dart';

class ARObjectsChats extends StatefulWidget {
  const ARObjectsChats({super.key});

  @override
  State<ARObjectsChats> createState() => _ARObjectsChatsState();
}

class _ARObjectsChatsState extends State<ARObjectsChats>
    with TickerProviderStateMixin {
  final Location _location = Location();
  final ARObjectChatService _arChat = ARObjectChatService();

  LocationData? _currentLocation;
  bool _loading = true;
  String? _error;

  String _query = "";
  String _sort = "distance";

  final List<Map<String, dynamic>> _arObjects = [
    {
      "id": "ar_001",
      "name": "Floating Hologram",
      "owner": "MetaLina",
      "lat": 30.045300,
      "lng": 31.235100,
      "icon": Icons.blur_on,
      "online": 5,
      "rarity": "Rare",
    },
    {
      "id": "ar_portal",
      "name": "Portal Gate",
      "owner": "Omar",
      "lat": 30.044820,
      "lng": 31.232900,
      "icon": Icons.vrpano,
      "online": 12,
      "rarity": "Legendary",
    },
    {
      "id": "ar_digital",
      "name": "Digital Artifact",
      "owner": "MetaGirl",
      "lat": 30.043500,
      "lng": 31.230820,
      "icon": Icons.auto_awesome,
      "online": 4,
      "rarity": "Common",
    },
    {
      "id": "ar_cube",
      "name": "AR Treasure Cube",
      "owner": "NileMaster",
      "lat": 30.046100,
      "lng": 31.233400,
      "icon": Icons.view_in_ar,
      "online": 7,
      "rarity": "Epic",
    },
  ];

  List<Map<String, dynamic>> _computed = [];

  @override
  void initState() {
    super.initState();
    _computed = _arObjects.map((o) => {...o, "distanceMeters": null}).toList();
    _initLocation();
  }

  // ===============================
  // NAVIGATION
  // ===============================
  void _openObjectComments(Map<String, dynamic> obj) async {
    await _arChat.ensureARObject(
      objectId: obj["id"],
      name: obj["name"],
      lat: obj["lat"],
      lng: obj["lng"],
    );


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARObjectDetailsScreen(
          objectId: obj["id"],
          objectName: obj["name"],
        ),
      ),
    );

  }



  // ===============================
  // LOCATION
  // ===============================
  Future<void> _initLocation() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });;

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _fail("Location service disabled");
          return;
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied ||
          permission == PermissionStatus.deniedForever) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          _fail("Location permission denied");
          return;
        }
      }

      _currentLocation = await _location.getLocation();
      _computeDistances();

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      _fail("Failed to get location");
    }
  }

  void _fail(String msg) {
    if (!mounted) return;

    setState(() {
      _loading = false;
      _error = msg;
    });
  }

  // ===============================
  // DISTANCE CALC
  // ===============================
  double _rad(double deg) => deg * pi / 180;

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) *
            cos(_rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  void _computeDistances() {
    if (_currentLocation == null) return;

    final lat = _currentLocation!.latitude!;
    final lng = _currentLocation!.longitude!;

    _computed = _arObjects.map((obj) {
      final d = _distance(lat, lng, obj["lat"], obj["lng"]);
      return {...obj, "distanceMeters": d};
    }).toList();

    _sortData();
  }

  // ===============================
  // SORT & FILTER
  // ===============================
  void _sortData() {
    if (_sort == "distance") {
      _computed.sort((a, b) =>
          (a["distanceMeters"] ?? double.infinity)
              .compareTo(b["distanceMeters"] ?? double.infinity));
    } else if (_sort == "online") {
      _computed.sort((a, b) => b["online"].compareTo(a["online"]));
    } else if (_sort == "rarity") {
      const power = {"Legendary": 4, "Epic": 3, "Rare": 2, "Common": 1};
      _computed.sort(
              (a, b) => power[b["rarity"]]!.compareTo(power[a["rarity"]]!));
    }
    setState(() {});
  }

  List<Map<String, dynamic>> _filtered() {
    if (_query.isEmpty) return _computed;
    return _computed
        .where((e) =>
        (e["name"] as String).toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  // ===============================
  // UI HELPERS
  // ===============================
  String _distanceLabel(double? d) =>
      d == null ? "—" : d < 1000 ? "${d.toInt()} m" : "${(d / 1000).toStringAsFixed(1)} km";

  Color _rarityColor(String r) {
    switch (r) {
      case "Legendary":
        return Colors.amberAccent;
      case "Epic":
        return Colors.purpleAccent;
      case "Rare":
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  // ===============================
  // BUILD
  // ===============================
  @override
  Widget build(BuildContext context) {
    final list = _filtered();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initLocation,
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _searchBar()),
                if (_loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_error != null)
                  SliverToBoxAdapter(child: _errorWidget())
                else
                  _grid(list),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Column(
    children: [
      const SizedBox(height: 18),
      Text(
        "AR Objects Chats",
        style: GoogleFonts.inter(
          color: AppColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        "Join live chats of AR objects around you",
        style: TextStyle(color: AppColors.textLight, fontSize: 13),
      ),
    ],
  );

  Widget _searchBar() => Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: "Search objects...",
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      const SizedBox(width: 10),
      PopupMenuButton<String>(
        onSelected: (v) {
          _sort = v;
          _sortData();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: "distance", child: Text("Distance")),
          PopupMenuItem(value: "online", child: Text("Online")),
          PopupMenuItem(value: "rarity", child: Text("Rarity")),
        ],
        child: const Icon(Icons.sort),
      )
    ],
  );

  Widget _errorWidget() => Center(
    child: Column(
      children: [
        Text(_error!, style: TextStyle(color: AppColors.textSoft)),
        ElevatedButton(onPressed: _initLocation, child: const Text("Retry")),
      ],
    ),
  );

  SliverGrid _grid(List<Map<String, dynamic>> list) => SliverGrid(
    delegate: SliverChildBuilderDelegate(
          (c, i) => _objectCard(list[i]),
      childCount: list.length,
    ),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: .94,
    ),
  );

  Widget _objectCard(Map obj) {
    final rc = _rarityColor(obj["rarity"]);
    return GestureDetector(
      onTap: () => _openObjectComments(Map<String, dynamic>.from(obj)),
        child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(obj["icon"], size: 42, color: rc),
            const SizedBox(height: 10),
            Text(obj["name"],
                style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600)),
            Text(_distanceLabel(obj["distanceMeters"]),
                style: TextStyle(color: AppColors.textSoft)),
          ],
        ),
      ),
    );
  }
}
