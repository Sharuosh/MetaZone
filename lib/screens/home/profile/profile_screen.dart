// File: lib/screens/home/profile/profile_screen.dart
// MetaZone — Profile Screen (Hologram Hybrid V3 • Improved, Organized)

import 'dart:io';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/theme.dart';
import '../settings/main_settings_screen.dart';
import 'edit/edit_profile_screen.dart';
import 'widgets/followers_screen.dart';
import 'widgets/following_screen.dart';
import '../../wallet/wallet_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/user_service.dart';


class ProfileScreen extends StatefulWidget {
  final String? userId;
  final Function(String)? onThemeChanged;

  const ProfileScreen({super.key, this.userId, this.onThemeChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  User? firebaseUser;
  final UserService _userService = UserService();

  bool isFollowing = false;
  Future<void> _loadFollowState() async {
    final me = firebaseUser!.uid;
    final target = widget.userId ?? me;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(me)
        .get();

    final list = List<String>.from(doc['followingList'] ?? []);

    setState(() => isFollowing = list.contains(target));
  }

  int nearbyRank = 7;


  String displayName = "";
  String username = "";
  String metaId = "";
  String bio = "";
  String email = "";
  String avatarUrl = "";
  bool verified = false;

  int xp = 0;
  int arSpots = 0;
  int virtualItems = 0;
  int followers = 0;
  int following = 0;

  String website = "https://meta-zone.example";

  Map<String, String> socialLinks = {
    "Twitter": "https://twitter.com/meta_explorer",
    "Instagram": "https://instagram.com/meta_explorer",
    "LinkedIn": "https://linkedin.com/in/meta_explorer",
  };






  File? avatarFile;
  final ImagePicker picker = ImagePicker();

  late final AnimationController _animCtrl;
  late final Animation<double> _pulse;
  late final Animation<double> _tilt;

  // Tabs
  late final TabController _tabCtrl;

  // UX helpers
  int get level => (xp / 1000).floor() + 1;
  double get progress {
    final base = (level - 1) * 1000;
    return ((xp - base) / 1000).clamp(0.0, 1.0);
  }

  Color _rankColor() {
    if (xp >= 5000) return AppColors.primary;
    if (xp >= 2000) return AppColors.primary.withOpacity(.7);
    return AppColors.textLight;
  }

  @override
  void initState()

  {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulse = Tween(begin: 0.98, end: 1.04).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));

    _tilt = Tween(begin: -0.012, end: 0.012).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));

    _tabCtrl = TabController(length: 4, vsync: this);
    firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {

      // تأكيد إنشاء وثيقة المستخدم إن لم تكن موجودة
      _userService.ensureUserDoc(firebaseUser!.uid);
      if (widget.userId != null && widget.userId != firebaseUser!.uid) {
        _loadFollowState();
      }
      FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser!.uid)
          .set({
        "profileUrl": "https://meta-zone.app/u/${firebaseUser!.uid}",
      }, SetOptions(merge: true));

      FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser!.uid)
          .snapshots()
          .listen((doc) {
        if (!doc.exists) return;

        final data = doc.data()!;

        setState(() {
          displayName = data['displayName'] ?? "";
          username = data['username'] ?? "";
          email = data['email'] ?? "";
          metaId = data['metaId'] ?? firebaseUser!.uid;
          bio = data['bio'] ?? "";
          avatarUrl = data['photoUrl'] ?? "";
          verified = data['verified'] ?? false;

          xp = data['xp'] ?? 0;
          arSpots = data['arSpotsCount'] ?? 0;
          virtualItems = data['creationsCount'] ?? 0;

          followers = data['followers'] ?? 0;
          following = data['following'] ?? 0;
        });
      });
    }


  }


  @override
  void dispose() {
    _animCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ---------------------------
  // Avatar picker
  // ---------------------------
  Future<void> _pickAvatar(ImageSource src) async {
    final picked = await picker.pickImage(source: src, imageQuality: 72);
    if (picked == null) return;

    final uid = firebaseUser?.uid;
    if (uid == null) return;

    final url = await _userService.uploadAvatar(
      uid,
      File(picked.path),
      oldUrl: avatarUrl,
    );

    if (url != null) {
      setState(() => avatarUrl = url);
    }
  }


  void _chooseAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text("Take Photo", style: AppTextStyles.body()),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo, color: AppColors.primary),
              title: Text("Choose from Gallery", style: AppTextStyles.body()),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // QR + Link helpers
  // ---------------------------
  void _showFullQR() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("MetaZone QR", style: AppTextStyles.title()),
              const SizedBox(height: 12),
              QrImageView(
                data: "https://metaz.one/u/$username",
                size: 220,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _copyProfileLink() {
    Clipboard.setData(ClipboardData(text: "metazone://user/$metaId"));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile link copied")),
    );
  }

  // ---------------------------
  // Edit profile route
  // ---------------------------
  void _openEdit() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          displayName: displayName,
          username: username,
          bio: bio,
          socialLinks: Map.from(socialLinks),
          avatarFile: avatarFile,
        ),
      ),
    );

    if (updated is Map<String, dynamic>) {
      setState(() {
        displayName = updated["displayName"] ?? displayName;
        username = updated["username"] ?? username;
        bio = updated["bio"] ?? bio;
        socialLinks =
        Map<String, String>.from(updated["socialLinks"] ?? socialLinks);
        avatarFile = updated["avatarFile"] ?? avatarFile;
      });
    }
  }

  void _toggleFollow() async {
    final me = firebaseUser?.uid;
    final target = widget.userId ?? firebaseUser?.uid;

    if (me == null || target == null) return;
    if (me == target) return;

    setState(() => isFollowing = !isFollowing);

    if (isFollowing) {
      await _userService.follow(me, target);
    } else {
      await _userService.unfollow(me, target);
    }

    _loadFollowState();
  }



  // ---------------------------
  // Open followers/following screens
  // ---------------------------
  void _openFollowers() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowersScreen()));
  }

  void _openFollowing() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowingScreen()));
  }

  // ---------------------------
  // AR Control Panel (bottom sheet)
  // ---------------------------
  void _openARControlPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (context, ctrl) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(color: AppColors.border.withOpacity(0.4)),
            ),
            child: ListView(
              controller: ctrl,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(width: 12),
                    Text("AR Control Panel", style: AppTextStyles.title()),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSoft),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Manage your portals, live events, publish creations and monitor active users from here.",
                  style: AppTextStyles.caption(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _smallInfo("Portals", arSpots.toString(), Icons.vrpano),
                    const SizedBox(width: 8),
                    _smallInfo("Live", "3", Icons.group),
                    const SizedBox(width: 8),
                    _smallInfo("Items", virtualItems.toString(), Icons.widgets),
                  ],
                ),
                const SizedBox(height: 14),
                Text("Actions", style: AppTextStyles.title()),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _actionChip(Icons.add_circle, "Create Portal", () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Create Portal (placeholder)")),
                      );
                    }),
                    _actionChip(Icons.event, "Schedule Event", () {}),
                    _actionChip(Icons.cloud_upload, "Publish Item", () {}),
                    _actionChip(Icons.analytics, "Analytics", () {}),
                    _actionChip(Icons.visibility, "Toggle Visibility", () {}),
                  ],
                ),
                const SizedBox(height: 18),
                Text("Published Portals", style: AppTextStyles.title()),
                const SizedBox(height: 10),
                Column(
                  children: List.generate(arSpots, (i) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.card,
                        child: Text("P${i + 1}", style: TextStyle(color: AppColors.primary)),
                      ),
                      title: Text("Portal #${i + 1}", style: AppTextStyles.title(size: 13)),
                      subtitle: Text("Active • ${10 + i} visitors", style: AppTextStyles.caption()),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                        child: const Text("Open"),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _smallInfo(String t, String v, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(v, style: AppTextStyles.title(size: 14)),
            Text(t, style: AppTextStyles.caption()),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.caption()),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // UI building blocks
  // ---------------------------
  Widget _avatarWidget() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) => Transform.rotate(
        angle: _tilt.value,
        child: Transform.scale(
          scale: _pulse.value,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.neonGradient,
                ),
                padding: const EdgeInsets.all(6),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.card,


                  child: avatarFile == null && avatarUrl.isEmpty
                      ? Text(
                    displayName.isNotEmpty ? displayName[0] : "?",
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  )
                      : null,

                ),
              ),
              GestureDetector(
                onTap: _chooseAvatar,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.black, size: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayName, style: AppTextStyles.heading(size: 20)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "@${username.isEmpty ? "guest" : username}",
              style: AppTextStyles.caption(),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.cardSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(metaId, style: AppTextStyles.caption(size: 11)),
            ),
            const SizedBox(width: 8),
            if (verified) Icon(Icons.verified, size: 16, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 8),
        Text(bio, style: AppTextStyles.body()),
        const SizedBox(height: 10),

        // Personal action row (Followers / Following / Contact / Media)
        Row(
          children: [
            _compactStatButton("Followers", followers.toString(), _openFollowers),
            const SizedBox(width: 8),
            _compactStatButton("Following", following.toString(), _openFollowing),
            const SizedBox(width: 8),
            if ((widget.userId ?? firebaseUser?.uid) != firebaseUser?.uid)
              ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? AppColors.card : AppColors.primary,
                  foregroundColor: isFollowing ? AppColors.text : Colors.black,
                ),
                child: Text(isFollowing ? "Following" : "Follow"),
              ),

            const Spacer(),
            IconButton(
              onPressed: _openARControlPanel,
              icon: Icon(Icons.vrpano, color: AppColors.primary),
            ),
          ],
        )
      ],
    );
  }

  Widget _compactStatButton(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.title(size: 14)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption(size: 11)),
          ],
        ),
      ),
    );
  }

  Widget _statBlock(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.title(size: 14)),
        Text(title, style: AppTextStyles.caption(size: 11)),
      ],
    );
  }

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBlock("AR Spots", arSpots.toString(), Icons.public),
          _statBlock("Items", virtualItems.toString(), Icons.widgets),
          _statBlock("Rank", "#$nearbyRank", Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _xpCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Level $level",
                  style:
                  TextStyle(color: _rankColor(), fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Text("$xp XP", style: AppTextStyles.caption()),
              const Spacer(),
              Text("${(progress * 100).toInt()}%", style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.cardSoft,
              valueColor: AlwaysStoppedAnimation<Color>(_rankColor()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showFullQR,
            child: QrImageView(
              data: "metazone://user/$metaId",
              size: 96,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Meta ID", style: AppTextStyles.title()),
                const SizedBox(height: 4),
                Text(metaId, style: AppTextStyles.body()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(onPressed: _showFullQR, child: const Text("View QR")),
                    const SizedBox(width: 10),
                    OutlinedButton(onPressed: _copyProfileLink, child: const Text("Copy Link")),
                    OutlinedButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: "https://meta.zone/user/$metaId"),
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Link copied")));
                      },
                      child: const Text("Share"),
                    ),

                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------------------------
  // Tabs content
  // ---------------------------
  Widget _overviewTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _statsCard(),
        const SizedBox(height: 12),
        _xpCard(),
        const SizedBox(height: 16),
        Text("Achievements", style: AppTextStyles.title()),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _badge("Galaxy Explorer", "Visited 10 spots", Icons.travel_explore),
              _badge("Top Creator", "Published 5 items", Icons.auto_awesome),
              _badge("Builder", "20 Items", Icons.handyman),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SizedBox(height: 18),
        Text("Social Links", style: AppTextStyles.title()),
        const SizedBox(height: 8),
        Column(
          children: socialLinks.entries.map((e) {
            return ListTile(
              tileColor: AppColors.card,
              leading: Icon(Icons.link, color: AppColors.primary),
              title: Text(e.key),
              subtitle: Text(e.value, style: AppTextStyles.caption()),
              onTap: () {},
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _arSpotsTab() {
    final spots = List.generate(arSpots, (i) {
      return <String, Object?>{
        "id": "portal_${i + 1}",
        "title": "Portal #${i + 1}",
        "visitors": 10 + i,
        "active": i % 3 == 0,
      };
    });

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: spots.length,
      itemBuilder: (_, i) {
        final Map<String, Object?> s = spots[i];
        final String title = (s["title"] as String?) ?? "Portal";
        final String visitors = s["visitors"]?.toString() ?? "0";
        final bool active = s["active"] as bool? ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.cardSoft,
                child: Text("${i + 1}", style: TextStyle(color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title(size: 14)),
                    const SizedBox(height: 6),
                    Text("$visitors visitors • ${active ? "Live" : "Idle"}",
                        style: AppTextStyles.caption(size: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Open Portal (placeholder)")));
                },
                child: const Text("Open"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _creationsTab() {
    final items = List.generate(virtualItems, (i) => "Item ${i + 1}");
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.78),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final name = items[i];
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.view_in_ar, size: 36, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(name, style: AppTextStyles.caption(size: 12), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mediaTab() {
    final dummy = List.generate(24, (i) => "https://picsum.photos/seed/p$i/400");
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dummy.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemBuilder: (_, i) {
        final url = dummy[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                transitionDuration: const Duration(milliseconds: 260),
                pageBuilder: (_, __, ___) => Scaffold(
                  backgroundColor: Colors.black.withOpacity(.9),
                  body: Center(child: Image.network(url, fit: BoxFit.contain)),
                ),
              ),
            );
          },
          child: Hero(
            tag: url,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _badge(String title, String sub, IconData icon) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title(size: 13)),
                Text(sub, style: AppTextStyles.caption(size: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ============================
  // QR SHEET + SHARE PROFILE LINK
  // ============================


  Future<void> _showQrSheet() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final data = snap.data()!;

    final profileUrl = data["profileUrl"] ??
        "https://meta-zone.app/u/${data["username"]}";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set({"profileUrl": profileUrl}, SetOptions(merge: true));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Share your MetaZone Profile",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: profileUrl,
                  size: 220,
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                profileUrl,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Share.share(profileUrl);
                },
                icon: Icon(Icons.share),
                label: Text("Share profile"),
              ),
            ],
          ),
        );
      },
    );
  }


  // ---------------------------
  // Render
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(

        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Profile", style: AppTextStyles.heading()),
        actions: [
          IconButton(
            onPressed: _openEdit,
            icon: Icon(Icons.edit, color: AppColors.textLight),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MainSettingsScreen()));
            },

            icon: Icon(Icons.settings, color: AppColors.textLight),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logout معطّل مؤقتًا أثناء وضع التطوير"),
                ),
              );
            },
            icon: Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: Column(
        children: [
          // TOP INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatarWidget(),
                const SizedBox(width: 16),
                Expanded(child: _headerBlock()),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletHomeScreen()),
                      );
                    },
                    icon: Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: _showFullQR,
                    icon: Icon(Icons.qr_code, color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: _copyProfileLink,
                    icon: Icon(Icons.share, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _openARControlPanel,
              icon: const Icon(Icons.hub_rounded),
              label: const Text("AR Command Center"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),


          // TAB BAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSoft,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(.12),
              ),
              tabs: const [
                Tab(text: "Overview"),
                Tab(text: "AR Spots"),
                Tab(text: "Creations"),
                Tab(text: "Media"),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _overviewTab(),
                _arSpotsTab(),
                _creationsTab(),
                _mediaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
