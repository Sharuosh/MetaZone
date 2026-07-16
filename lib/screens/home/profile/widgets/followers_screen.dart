import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../profile_screen.dart';
import 'profile_preview.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  late List<Map<String, dynamic>> _items;
  late List<Map<String, dynamic>> _filtered;

  @override
  void initState() {
    super.initState();
    _loadFakeFollowers();
  }

  void _loadFakeFollowers() {
    final names = [
      "Lina","Omar","Noor","Youssef","Sara","Khaled",
      "Mona","Tamer","Nadine","Hassan","Rania","Adel"
    ];

    _items = List.generate(names.length, (i) {
      return {
        "name": names[i],
        "username": names[i].toLowerCase(),
        "bio": i % 2 == 0 ? "AR Creator • Explorer" : "MetaZone user",
        "online": i % 4 == 0,
        "mutual": i % 3 == 0 ? 2 : 0,
        "isFollowing": i % 5 == 0, // 👈 مهم
      };
    });

    _filtered = List.from(_items);
  }

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

  // ---------------------------------------------------
  // Open full profile
  // ---------------------------------------------------
  void _openProfile(Map<String, dynamic> it) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _toggleFollow(int index) {
    setState(() {
      _filtered[index]["isFollowing"] =
      !_filtered[index]["isFollowing"];
    });
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
        title: Text("Followers", style: AppTextStyles.heading()),
      ),
      body: Column(
        children: [
          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: TextField(
              controller: _searchCtl,
              onChanged: _search,
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: "Search followers...",
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

          // ================= LIST =================
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Text(
                "No followers found",
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
