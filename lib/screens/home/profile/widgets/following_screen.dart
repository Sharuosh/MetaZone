// MetaZone — Following Screen (Ultra Pro • Unified Design)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../profile_screen.dart';
import 'profile_preview.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  late List<Map<String, dynamic>> _items;
  late List<Map<String, dynamic>> _filtered;

  @override
  void initState() {
    super.initState();
    _loadDemoFollowing();
  }

  void _loadDemoFollowing() {
    final names = [
      "MetaShop",
      "Rania",
      "Ahmed",
      "Nora",
      "Ziad",
      "Hala",
      "Issa",
      "Mariam",
      "Kareem",
      "Dina"
    ];

    _items = List.generate(names.length, (i) {
      final n = names[i];
      return {
        "id": "f$i",
        "name": n,
        "username": n.toLowerCase(),
        "bio": i % 3 == 0 ? "AR Creator • MetaZone Active" : "MetaZone User",
        "online": i % 4 == 0,
        "mutual": i % 3 == 0 ? 2 : 0,
        "isFollowing": true, // 👈 أساسي
      };
    });

    _filtered = List.from(_items);
  }

  // Search
  void _search(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) {
      setState(() => _filtered = List.from(_items));
      return;
    }

    setState(() {
      _filtered = _items.where((it) {
        return it["name"].toLowerCase().contains(s) ||
            it["username"].toLowerCase().contains(s) ||
            it["bio"].toLowerCase().contains(s);
      }).toList();
    });
  }

  // Open profile
  void _openProfile(Map<String, dynamic> u) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  // Unfollow
  void _toggleFollow(int index) {
    final name = _filtered[index]["name"];

    setState(() {
      _filtered[index]["isFollowing"] = false;
      _items.removeWhere((x) => x["id"] == _filtered[index]["id"]);
      _filtered.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Unfollowed $name"),
        backgroundColor: AppColors.surfaceSoft,
      ),
    );
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Following", style: AppTextStyles.heading()),
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: TextField(
              controller: _searchCtl,
              onChanged: _search,
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: "Search following...",
                hintStyle: AppTextStyles.caption(),
                prefixIcon: Icon(Icons.search, color: AppColors.textSoft),
                filled: true,
                fillColor: AppColors.cardSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Text(
                "You are not following anyone",
                style: AppTextStyles.caption(),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(top: 4),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final it = _filtered[i];
                return ProfilePreview(
                  name: it["name"],
                  username: it["username"],
                  bio: it["bio"],
                  isOnline: it["online"],
                  mutual: it["mutual"],
                  isFollowing: it["isFollowing"],
                  onOpenProfile: () => _openProfile(it),
                  onFollow: () => _toggleFollow(i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
