// File: lib/screens/home/home_screen.dart
// MetaZone — Home (2025 Clean Edition) with AR Super Menu

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'package:flutter/rendering.dart';

// MAIN MODULES
import '../ar/create/ar_hub_screen.dart';
import '../ar/map/map_screen.dart';

import '../ar/global_search/search_screen.dart';

// HOME MODULES
import 'modules/nearby_ar_screen.dart';
import 'modules/trending_ar_screen.dart';
import 'modules/teleport_rooms_module.dart';
import 'live_ar_feed_screen.dart';
import 'ai/ask_mz_ai_screen.dart';
import 'explore/explore_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';
import 'my_zones/my_zones_screen.dart';

// MARKETPLACE (TopBar Only)
import '../marketplace/home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final List<Map<String, String>> _liveFeed = List.generate(4, (i) => {
    "id": "live_$i",
    "title": ["Nile Gate Live", "Neon Mural", "Sky Lantern", "City AR"][i],
    "subtitle": "Creator ${i + 1}",
    "image": "https://picsum.photos/seed/live$i/1200/720",
  });

  final List<Map<String, String>> _nearby = List.generate(6, (i) => {
    "id": "nearby_$i",
    "title": "Nearby ${i + 1}",
    "subtitle": "Creator ${i + 10}",
    "image": "https://picsum.photos/seed/nearby$i/900/540",
    "distance": "${(i + 1) * 110}m",
  });

  final List<Map<String, String>> _trending = List.generate(6, (i) => {
    "id": "trend_$i",
    "title": "Portal ${i + 1}",
    "image": "https://picsum.photos/seed/trend$i/900/900"
  });

  final List<Map<String, dynamic>> _myZones = List.generate(
    3,
        (i) => {
      "id": "zone_$i",
      "title": "My Zone ${i + 1}",
      "image": "https://picsum.photos/seed/zone$i/900/500",
      "visits": (i + 1) * 1200,
      "progress": 0.25 * (i + 1),
    },
  );

  late final PageController _livePageCtrl;
  late final ScrollController _scrollCtrl;

  int _liveIndex = 0;
  bool _showAI = true;

  late final AnimationController _aiPulse;
  late final Animation<double> _aiScale;

  // AR Super Menu pulse controller
  late final AnimationController _arPulse;
  late final Animation<double> _arScale;
  late final Animation<double> _arGlowOpacity;

  @override
  void initState() {
    super.initState();

    _livePageCtrl = PageController(viewportFraction: .86);
    _scrollCtrl = ScrollController();

    _arPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _arScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _arPulse, curve: Curves.easeInOut),
    );

    _arGlowOpacity = Tween<double>(begin: .55, end: .98).animate(
      CurvedAnimation(parent: _arPulse, curve: Curves.easeInOut),
    );

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showAI) setState(() => _showAI = false);
      } else if (_scrollCtrl.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showAI) setState(() => _showAI = true);
      }
    });
  }

  @override
  void dispose() {
    _livePageCtrl.dispose();
    _scrollCtrl.dispose();
    _arPulse.dispose();
    super.dispose();
  }

  void _open(Widget screen) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => screen),
  );

  // =============================================================
  //                          BUILD UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async =>
              await Future.delayed(const Duration(milliseconds: 450)),
              child: ListView(
                padding: const EdgeInsets.all(18),
                controller: _scrollCtrl,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 18),

                  _buildMapHeroCard(),
                  const SizedBox(height: 18),

                  _buildExploreTeleportCard(),
                  const SizedBox(height: 22),


                  _section("My Zones", "Manage",
                          () => _open(const MyZonesScreen())),
                  const SizedBox(height: 12),
                  _myZonesPreview(),
                  const SizedBox(height: 22),

                  _section("Nearby Spots", "Map",
                          () => _open(const ARMapScreen())),
                  const SizedBox(height: 12),
                  _nearbyCarousel(),
                  const SizedBox(height: 22),

                  _section("Trending Portals", "Explore",
                          () => _open(const TrendingARScreen())),
                  const SizedBox(height: 12),
                  _trendingGrid(),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: 170, // فوق زر AR
            child: GestureDetector(
              onTap: () => _open(const AskMetaZoneAI()),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface, // هادي
                  border: Border.all(
                    color: AppColors.primary.withOpacity(.4),
                  ),


                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.25),
                      blurRadius: 14,
                    )
                  ],
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // ================= AR HUB SIDE BUTTON =================
          Positioned(
            right: -6, // نصفه بره الشاشة (ستايل برو)
            top: MediaQuery.of(context).size.height * 0.38,
            child: GestureDetector(
              onTap: () => _open(const ARHubScreen()),
              child: AnimatedBuilder(
                animation: _arPulse,
                builder: (_, __) {
                  return Transform.scale(
                    scale: _arScale.value,
                    child: Container(
                      width: 58,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: AppColors.neonGradient,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primarySoft,
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.hub_rounded,
                              color: Colors.black, size: 28),
                          SizedBox(height: 6),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              "AR HUB",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );
  }

  // =============================================================
  //                          ORIGINAL WIDGETS
  // =============================================================
  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _open(ProfileScreen(onThemeChanged: null)),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(.12),
            backgroundImage: const AssetImage("assets/images/user.png"),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("AR MODE", style: AppTextStyles.caption(size: 11)),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text("Abdelrahman", style: AppTextStyles.heading(size: 20)),
            ],
          ),
        ),


        IconButton(
          onPressed: () => _open(const GlobalSearchScreen()),
          icon: Icon(Icons.search, color: AppColors.text),
        ),
        IconButton(
          onPressed: () => _open(const NotificationsScreen()),
          icon: Icon(Icons.notifications_none, color: AppColors.text),
        ),

        // 🔥 Marketplace FIXED Here
        GestureDetector(
          onTap: () => _open(MarketplaceHomeScreen()),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withOpacity(.4)),
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildMapHeroCard() {
    return GestureDetector(
      onTap: () => _open(const ARMapScreen()),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              AppColors.surface.withOpacity(.85),
              AppColors.card.withOpacity(.95),
            ],
          ),
          border: Border.all(color: AppColors.primary.withOpacity(.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.25),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AR MAP", style: AppTextStyles.heading(size: 18)),
                  const SizedBox(height: 6),
                  Text(
                    "Launch spatial view & nearby zones",
                    style: AppTextStyles.caption(size: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 6),
                      Text("Start AR",
                          style: AppTextStyles.caption(
                              size: 12, color: AppColors.primary)),
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary,
                    blurRadius: 32,
                  ),
                ],
              ),
              child: const Icon(
                Icons.public_rounded,
                size: 40,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildExploreTeleportCard() {
    return Row(
      children: [
        Expanded(
          child: _hudAction(
            icon: Icons.explore_rounded,
            title: "Explore",
            subtitle: "AR worlds",
            onTap: () => _open(const ExploreScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _hudAction(
            icon: Icons.vrpano_rounded,
            title: "Teleport",
            subtitle: "Instant jump",
            onTap: () => _open(const TeleportRoomsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _hudAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title(size: 14)),
                Text(subtitle, style: AppTextStyles.caption(size: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _exploreTeleportItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.neonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.black, size: 30),
        ),
        const SizedBox(height: 8),
        Text(title, style: AppTextStyles.title(size: 14)),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.caption(size: 11)),
      ],
    );
  }


  Widget _quickActions() {
    final actions = [
// فاضي
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(.6)),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .95,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () => _open(a["screen"] as Widget),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: AppColors.neonGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primarySoft,
                        blurRadius: 18,
                      )
                    ],
                  ),
                  child: Icon(a["icon"] as IconData, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  a["label"] as String,
                  style: AppTextStyles.caption(size: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _liveCarousel() {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _livePageCtrl,
              itemCount: _liveFeed.length,
              onPageChanged: (i) => setState(() => _liveIndex = i),
              itemBuilder: (_, i) {
                final item = _liveFeed[i];
                final active = i == _liveIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: EdgeInsets.only(
                    right: 14,
                    left: i == 0 ? 2 : 0,
                    top: active ? 0 : 10,
                    bottom: active ? 0 : 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.22),
                          blurRadius: 14)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            item["image"]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withOpacity(.35),
                                  Colors.transparent
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["title"]!,
                                  style: AppTextStyles.title(size: 16)
                                      .copyWith(color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(item["subtitle"]!,
                                  style: AppTextStyles.caption()
                                      .copyWith(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _indicator(_liveFeed.length, _liveIndex),
        ],
      ),
    );
  }

  Widget _indicator(int count, int active) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active == i ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
            active == i ? AppColors.primary : AppColors.textSoft.withOpacity(.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _myZonesPreview() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        itemCount: _myZones.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final z = _myZones[i];
          return GestureDetector(
            onTap: () => _open(const MyZonesScreen()),
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(.6)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: Image.network(
                      z["image"],
                      width: 100,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(z["title"],
                              style: AppTextStyles.title(size: 14)),
                          const SizedBox(height: 4),
                          Text("${z["visits"]} visits",
                              style: AppTextStyles.caption()),
                          const Spacer(),
                          LinearProgressIndicator(
                            value: z["progress"],
                            valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _nearbyCarousel() {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        itemCount: _nearby.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final n = _nearby[i];
          return GestureDetector(
            onTap: () => _open(const NearbyARScreen()),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border.withOpacity(.6)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.26),
                        blurRadius: 16)
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(n["image"]!, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(.28),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                            )),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n["title"]!,
                                  style: AppTextStyles.title(size: 14)
                                      .copyWith(color: Colors.white)),
                              const SizedBox(height: 3),
                              Text(n["subtitle"]!,
                                  style: AppTextStyles.caption()
                                      .copyWith(color: Colors.white70)),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(.6),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(n["distance"]!,
                                style: AppTextStyles.caption(size: 12)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _trendingGrid() {
    return GridView.builder(
      itemCount: _trending.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .9,
      ),
      itemBuilder: (_, i) {
        final t = _trending[i];
        return GestureDetector(
          onTap: () => _open(const TrendingARScreen()),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(t["image"]!, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(.28),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Text(t["title"]!,
                      style: AppTextStyles.title()
                          .copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return CustomPaint(
      painter: _NeonWavesPainter(),
      child: Container(),
    );
  }

  Widget _section(String title, [String? action, VoidCallback? onTap]) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.title(size: 16)),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style:
              AppTextStyles.caption().copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class _NeonWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < 10; i++) {
      final y = size.height * (.06 * i + .05);
      final path = Path();
      path.moveTo(0, y);
      path.quadraticBezierTo(
        size.width * .25,
        y + 12 * sin(i + 1),
        size.width * .5,
        y - 8 * cos(i + 2),
      );
      path.quadraticBezierTo(
        size.width * .75,
        y + 14 * sin(i + 1),
        size.width,
        y,
      );
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
