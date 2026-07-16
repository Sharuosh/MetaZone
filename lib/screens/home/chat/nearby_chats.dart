// lib/screens/home/chat/nearby_chats.dart
// MetaZone — Nearby AR Chats (PRO Edition – Full Connected Version)

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import '../../../core/theme/theme.dart';
import '../../../services/chat_service.dart';
import 'chat_screen.dart';

import 'user_profile_popup.dart';
import 'shared_media_screen.dart';

class NearbyChats extends StatefulWidget {
  const NearbyChats({super.key});

  @override
  State<NearbyChats> createState() => _NearbyChatsState();
}

class _NearbyChatsState extends State<NearbyChats>

    with SingleTickerProviderStateMixin {
  final Location _location = Location();
  final ChatService _chatService = ChatService();

  LocationData? _currentLocation;
  bool _loading = true;
  String? _error;
  String _query = "";
  bool _autoSort = true;

  final List<Map<String, dynamic>> _spots = [
    {
      "id": "ctower",
      "name": "Cairo Tower",
      "owner": "MetaLina",
      "lat": 30.045915,
      "lng": 31.224289,
      "icon": Icons.location_city,
      "online": 12,
      "unread": 1,
    },
    {
      "id": "tahrir",
      "name": "Tahrir Square",
      "owner": "Omar",
      "lat": 30.044420,
      "lng": 31.235712,
      "icon": Icons.public,
      "online": 6,
      "unread": 0,
    },
    {
      "id": "nile",
      "name": "Nile AR Spot",
      "owner": "NileMaster",
      "lat": 30.042000,
      "lng": 31.225000,
      "icon": Icons.waves,
      "online": 3,
      "unread": 0,
    },
    {
      "id": "meta12",
      "name": "MetaZone AR Portal #12",
      "owner": "MetaGirl",
      "lat": 30.043200,
      "lng": 31.238000,
      "icon": Icons.bubble_chart,
      "online": 9,
      "unread": 4,
    },
  ];

  late AnimationController _glowCtrl;
  List<Map<String, dynamic>> _computed = [];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initLocation();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _error = "Location service disabled";
            _loading = false;
          });
          return;
        }
      }

      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.deniedForever) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          setState(() {
            _error = "Location permission not granted";
            _loading = false;
          });
          return;
        }
      }

      _currentLocation = await _location.getLocation();
      _recompute();

      _location.onLocationChanged.listen((loc) {
        _currentLocation = loc;
        _recompute(refreshOnly: true);
      });

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = "Failed to get location";
        _loading = false;
      });
    }
  }

  double _rad(double deg) => deg * pi / 180;

  double _dist(double lat1, double lon1, double lat2, double lon2) {
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

  void _recompute({bool refreshOnly = false}) {
    if (_currentLocation == null) return;

    final lat = _currentLocation!.latitude!;
    final lng = _currentLocation!.longitude!;

    _computed = _spots.map((s) {
      final d = _dist(lat, lng, s['lat'], s['lng']);
      return {...s, "distance": d};
    }).toList();

    if (_autoSort) {
      _computed.sort((a, b) => a["distance"].compareTo(b["distance"]));
    }

    if (!refreshOnly) setState(() {});
  }

  // ----------------------------------------------------------
  // REQUIRED FIX → DIST LABEL
  // ----------------------------------------------------------
  String _distLabel(double? m) {
    if (m == null) return "—";
    return m < 1000 ? "${m.toInt()} m" : "${(m / 1000).toStringAsFixed(1)} km";
  }

  // ----------------------------------------------------------
  // REQUIRED FIX → ENTER CHAT FUNCTION
  // ----------------------------------------------------------
  Future<void> _enterChat(Map s) async {
    if (_currentLocation == null) return;

    final lat = s["lat"] as double;
    final lng = s["lng"] as double;

    // 👇 zoneId ثابت مبني على الـ spot
    final String zoneId = "nearby_${s['id']}";

    try {
      // 1️⃣ نجيب أو ننشئ Nearby ChatContext
      final doc = await _chatService.getNearbyContext(
        lat: lat,
        lng: lng,
        radiusMeters: 500, // نصف قطر المكان
        zoneId: zoneId,
        title: s["name"],
      );

      await _chatService.joinContext(
        "NEARBY",
        doc.id,
      );


      // 3️⃣ ندخل على ChatScreen بالـ contextId
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            contextType: "NEARBY",
            contextId: doc.id,
            contextName: s["name"],
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to enter chat")),
      );
    }
  }


  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_location_alt),
        label: const Text("Create Room"),
        onPressed: () {},
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initLocation,
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                _buildLocation(),
                _buildList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "Nearby AR Chats",
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: "Search nearby rooms...",
                      hintStyle: TextStyle(color: AppColors.textSoft),
                      prefixIcon:
                      Icon(Icons.search, color: AppColors.textSoft),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _autoSort = !_autoSort),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _autoSort
                        ? AppColors.primarySoft.withOpacity(.25)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sort_rounded,
                    color:
                    _autoSort ? AppColors.primary : AppColors.textSoft,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // LOCATION
  SliverToBoxAdapter _buildLocation() {
    if (_loading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            Text(_error!, style: TextStyle(color: AppColors.textSoft)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initLocation,
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            "Lat: ${_currentLocation?.latitude?.toStringAsFixed(4)}, "
                "Lng: ${_currentLocation?.longitude?.toStringAsFixed(4)}",
            style: TextStyle(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }

  // LIST
  SliverList _buildList() {
    final list = _computed.isNotEmpty ? _computed : _spots;

    if (list.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 40),
          Center(
            child: Text(
              "No nearby rooms found",
              style: TextStyle(color: AppColors.textSoft),
            ),
          )
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (ctx, i) => _spotCard(list[i]),
        childCount: list.length,
      ),
    );
  }

  // SPOT CARD
  Widget _spotCard(Map s) {
    final dist = s["distance"] as double? ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.2),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => UserProfilePopup(
                  userName: s["owner"],
                  userId: s["id"],
                ),
              );
            },
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, child) {
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySoft
                        .withOpacity(.25 * _glowCtrl.value),
                  ),
                  child:
                  Icon(s['icon'], color: AppColors.primary, size: 26),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s["name"],
                        style: GoogleFonts.inter(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (s["unread"] > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${s['unread']}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      )
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.location_pin,
                        size: 14, color: AppColors.textSoft),
                    const SizedBox(width: 6),
                    Text(
                      _distLabel(dist),
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.group,
                        size: 14, color: AppColors.textSoft),
                    const SizedBox(width: 4),
                    Text(
                      "${s['online']} online",
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: () => _enterChat(s),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text("Enter"),
          ),
        ],
      ),
    );
  }
}
