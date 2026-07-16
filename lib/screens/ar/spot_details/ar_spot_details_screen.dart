// lib/screens/ar/spot_details/ar_spot_details_screen.dart
// AR Spot Details — MetaZone (Polished & drop-in replacement)
// - Improved header visuals, like/save animations, full-screen media viewer
// - Objects list with View AR action, Reviews, Creator card
// - All visuals read from AppColors / AppTextStyles (use your existing theme)

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../create/ar_portal_viewer.dart';

// NOTE: This file expects AppColors, AppTextStyles and ARPortalViewerScreen to exist in your project.
// Replace or wire Firestore / network hooks where TODO markers are left.

class ARSpotDetailsScreen extends StatefulWidget {
  final String spotId;
  const ARSpotDetailsScreen({super.key, required this.spotId});

  @override
  State<ARSpotDetailsScreen> createState() => _ARSpotDetailsScreenState();
}

class _ARSpotDetailsScreenState extends State<ARSpotDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  Map<String, dynamic>? spot;
  bool _liked = false;
  bool _bookmarked = false;

  // animation for like heart
  late AnimationController _likeCtrl;
  late Animation<double> _likeScale;

  // hero tag base
  String get _heroImageTag => 'spot_image_${widget.spotId}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _likeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _likeScale = Tween<double>(begin: 1.0, end: 1.45).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.elasticOut));
    _loadSpot();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _likeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSpot() async {
    // Simulate network load — replace with Firestore / API fetch using widget.spotId
    await Future.delayed(const Duration(milliseconds: 300));
    spot = {
      "id": widget.spotId,
      "title": "Cairo Portal — Nile Gate",
      "description":
      "بوابة AR بتفتح تجربة هولوجرام نادرة فوق النيل. تجربة صوت وضوء وتفاعل جماعي.",
      "coverImage": "https://picsum.photos/seed/spot${widget.spotId}/1200/700",
      "views": 12800,
      "likes": 2940,
      "rating": 4.8,
      "activeUsers": 3,
      "distance": "240m",
      "rarity": "Legendary",
      "tags": ["Portal", "Nile", "Legendary"],
      "creator": {
        "id": "u001",
        "name": "MetaLina",
        "avatar": null,
        "portals": 17,
        "followers": 4000,
      },
      "objects": [
        {
          "id": "obj_001",
          "title": "Golden Falcon",
          "type": "3D Model",
          "rarity": "Rare",
          "likes": 2900,
          "views": 12000
        },
        {
          "id": "obj_002",
          "title": "Nebula Gate Frame",
          "type": "Portal Frame",
          "rarity": "Epic",
          "likes": 1020,
          "views": 5200
        },
      ],
      "reviews": [
        {
          "user": "Sara",
          "avatar": null,
          "text": "التجربة رهيبة جداً! لازم تجربوها بالليل 🔥",
          "rating": 5,
          "time": "2d"
        },
        {
          "user": "Omar",
          "avatar": null,
          "text": "حلو بس كان في lag بسيط عندي.",
          "rating": 4,
          "time": "6d"
        }
      ],
      "location": {"lat": 30.0459, "lng": 31.233},
    };

    setState(() => _loading = false);
  }

  void _enterAR() {
    if (spot == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARPortalViewerScreen(
          spotId: spot!["id"],
          title: spot!["title"],
          owner: spot!["creator"]["name"],
        ),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      if (_liked) {
        _likeCtrl.forward(from: 0.0);
        spot!["likes"] = (spot!["likes"] as int) + 1;
      } else {
        spot!["likes"] = max(0, (spot!["likes"] as int) - 1);
      }
    });

    // TODO: send like update to backend/firestore
  }

  void _toggleBookmark() {
    setState(() => _bookmarked = !_bookmarked);
    // TODO: persist saved spot to local DB or Firestore / update Saved Spots in Home
  }

  void _openShare() {
    // TODO: integrate Share.share from 'share_plus' package
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share (placeholder)')));
  }

  void _openFullMedia() {
    final image = spot?["coverImage"];
    if (image == null) return;
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => _FullScreenImageViewer(imageUrl: image, heroTag: _heroImageTag),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  // time ago helper (keeps your previous style)
  String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}functions.mz';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _header(),
          _statsRow(),
          _tabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _overviewTab(),
                _mediaTab(),
                _mapTab(),
                _objectsTab(),
              ],
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    final cover = spot!["coverImage"] as String?;
    return Stack(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: cover != null
              ? Hero(
            tag: _heroImageTag,
            child: Image.network(cover, fit: BoxFit.cover, width: double.infinity),
          )
              : Container(color: AppColors.card),
        ),

        // dark gradient overlay for readability
        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.35)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // header actions
        Positioned(
          left: 12,
          top: 34,
          right: 12,
          child: Row(
            children: [
              _glassIcon(Icons.arrow_back, () => Navigator.pop(context)),
              const Spacer(),
              _glassIcon(_bookmarked ? Icons.bookmark : Icons.bookmark_border, _toggleBookmark),
              const SizedBox(width: 8),
              _glassIcon(Icons.share, _openShare),
            ],
          ),
        ),

        // title block
        Positioned(
          left: 16,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(spot!["title"], style: AppTextStyles.title(size: 22)),
              const SizedBox(height: 6),
              Row(children: [
                Text("${spot!["distance"]} • ${spot!["activeUsers"]} active", style: AppTextStyles.caption()),
                const SizedBox(width: 10),
                _rarityBadge(spot!["rarity"]),
              ]),
            ],
          ),
        ),

        // tappable image overlay for full screen
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openFullMedia,
              splashColor: Colors.white24,
              highlightColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _rarityBadge(String? r) {
    if (r == null) return const SizedBox();
    Color c = AppColors.surface;
    switch (r.toLowerCase()) {
      case 'legendary':
        c = Colors.amberAccent;
        break;
      case 'epic':
        c = Colors.purpleAccent;
        break;
      case 'rare':
        c = AppColors.primary;
        break;
      default:
        c = AppColors.surface;
    }
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(r!, style: AppTextStyles.caption().copyWith(color: c)),
    );
  }

  // ---------------- STATS ROW ----------------
  Widget _statsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _stat(Icons.visibility, "${spot!["views"]}", "Views"),
          _divider(),
          _stat(Icons.vrpano, "${(spot!["objects"] as List).length}", "Objects"),
          _divider(),
          _stat(Icons.favorite, "${spot!["likes"]}", "Likes"),
          const Spacer(),
          // Like animated
          ScaleTransition(
            scale: _likeScale,
            child: IconButton(
              onPressed: _toggleLike,
              iconSize: 26,
              icon: Icon(_liked ? Icons.favorite : Icons.favorite_border, color: _liked ? Colors.redAccent : Colors.white70),
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: _enterAR,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: const Text("Enter AR"),
          )
        ],
      ),
    );
  }

  Widget _stat(IconData i, String v, String t) {
    return Row(
      children: [
        Icon(i, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v, style: AppTextStyles.body(size: 14)),
            Text(t, style: AppTextStyles.caption()),
          ],
        )
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 26, color: AppColors.border.withOpacity(0.6), margin: const EdgeInsets.symmetric(horizontal: 12));

  // ---------------- TAB BAR ----------------
  Widget _tabBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TabBar(
        controller: _tabController,
        indicator: _UnderlineParticleIndicator(color: AppColors.primary),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: "Overview"),
          Tab(text: "Media"),
          Tab(text: "Map"),
          Tab(text: "Objects"),
        ],
      ),
    );
  }

  // ---------------- TABS ----------------
  Widget _overviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Description", style: AppTextStyles.title(size: 16)),
        const SizedBox(height: 8),
        Text(spot!["description"], style: AppTextStyles.body()),
        const SizedBox(height: 16),
        Text("Tags", style: AppTextStyles.title(size: 16)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: List<String>.from(spot!["tags"]).map((t) => _tagChip("#$t")).toList()),
        const SizedBox(height: 18),
        Text("Creator", style: AppTextStyles.title(size: 16)),
        const SizedBox(height: 8),
        _creatorCard(),
        const SizedBox(height: 18),
        Text("Reviews", style: AppTextStyles.title(size: 16)),
        const SizedBox(height: 8),
        ..._reviews(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _mediaTab() {
    final cover = spot!["coverImage"] as String?;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          if (cover != null)
            GestureDetector(
              onTap: _openFullMedia,
              child: Hero(
                tag: _heroImageTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(cover, width: double.infinity, height: 220, fit: BoxFit.cover),
                ),
              ),
            )
          else
            Container(height: 220, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.broken_image))),
          const SizedBox(height: 12),
          Expanded(
            child: Center(child: Text("Additional media & gallery placeholder", style: AppTextStyles.caption())),
          ),
        ],
      ),
    );
  }

  Widget _mapTab() {
    // TODO: replace with GoogleMap / Mapbox widget and a marker for spot location
    final loc = spot!["location"] as Map<String, dynamic>?;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 72, color: AppColors.textSoft),
          const SizedBox(height: 12),
          Text("Map Placeholder", style: AppTextStyles.caption()),
          const SizedBox(height: 8),
          if (loc != null) Text("Lat: ${loc['lat']} , Lng: ${loc['lng']}", style: AppTextStyles.body(size: 12)),
        ],
      ),
    );
  }

  Widget _objectsTab() {
    final objs = List<Map<String, dynamic>>.from(spot!["objects"]);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: objs.length,
      itemBuilder: (_, i) => _objectItem(objs[i]),
    );
  }

  // ---------------- ELEMENTS ----------------
  Widget _creatorCard() {
    final c = spot!["creator"];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _neonBox(),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.surface, child: Text(c["name"][0])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c["name"], style: AppTextStyles.title(size: 14)),
              const SizedBox(height: 4),
              Text("${c["portals"]} portals • ${c["followers"]} followers", style: AppTextStyles.caption()),
            ]),
          ),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black), child: const Text("Follow")),
        ],
      ),
    );
  }

  List<Widget> _reviews() {
    final list = List<Map<String, dynamic>>.from(spot!["reviews"]);
    return list.map((r) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: _neonBox(),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: AppColors.surface, child: Text(r["user"][0])),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(r["user"], style: AppTextStyles.title(size: 13)), const Spacer(), Text(r["time"], style: AppTextStyles.caption())]),
                const SizedBox(height: 6),
                Text(r["text"], style: AppTextStyles.body(size: 13)),
              ]),
            )
          ],
        ),
      );
    }).toList();
  }

  Widget _tagChip(String text) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)), child: Text(text, style: AppTextStyles.caption()));
  }

  Widget _objectItem(Map<String, dynamic> o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _neonBox(),
      child: Row(
        children: [
          Container(width: 60, height: 60, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.widgets, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o["title"], style: AppTextStyles.title(size: 14)),
              const SizedBox(height: 4),
              Text("${o["type"]} • ${o["rarity"]}", style: AppTextStyles.caption()),
            ]),
          ),
          ElevatedButton(onPressed: _enterAR, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black), child: const Text("View AR")),
        ],
      ),
    );
  }

  // ---------------- BOTTOM BAR ----------------
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.98), border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.6)))),
      child: Row(children: [
        GestureDetector(
          onTap: _toggleLike,
          child: Row(children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: _liked ? const Icon(Icons.favorite, key: ValueKey('liked'), color: Colors.redAccent) : const Icon(Icons.favorite_border, key: ValueKey('unliked'), color: Colors.white70),
            ),
            const SizedBox(width: 8),
            Text("${spot!["likes"]}", style: AppTextStyles.body()),
          ]),
        ),
        const Spacer(),
        OutlinedButton.icon(onPressed: _toggleBookmark, icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border), label: Text(_bookmarked ? "Saved" : "Save")),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: _enterAR, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black), child: const Text("Enter AR")),
      ]),
    );
  }

  // ---------------- GLASS ICON ----------------
  Widget _glassIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.14))),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  BoxDecoration _neonBox() {
    return BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.6)), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 12, spreadRadius: 1)]);
  }
}

// -------------------- Full screen image viewer --------------------
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  const _FullScreenImageViewer({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
        Positioned(top: 40, left: 12, child: SafeArea(child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)))),
      ]),
    );
  }
}

// -------------------- Custom Tab Indicator (particle underline) --------------------
class _UnderlineParticleIndicator extends Decoration {
  final Color color;
  const _UnderlineParticleIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _UnderlineParticlePainter(color);
}

class _UnderlineParticlePainter extends BoxPainter {
  final Color color;
  _UnderlineParticlePainter(this.color);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final Rect rect = offset & config.size!;
    final Paint paint = Paint()..color = color..style = PaintingStyle.fill;

    final double cx = rect.center.dx;
    final double cy = rect.bottom - 6;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 40, height: 6), const Radius.circular(6)), paint);

    final rnd = Random(cx.toInt());
    for (int i = 0; i < 6; i++) {
      final dx = cx + rnd.nextDouble() * 24 - 12;
      final dy = cy + rnd.nextDouble() * 6 - 3;
      canvas.drawCircle(Offset(dx, dy), rnd.nextDouble() * 1.2, paint..color = color.withOpacity(0.6));
    }
  }
}
