import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/user_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final String username;

  const PublicProfileScreen({super.key, required this.username});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getUser() async {
    final snap = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: widget.username.toLowerCase())
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first;
  }

  Future<bool> _isFollowing(String myUid, String targetUid) async {
    final me = await FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .get();

    final list = List<String>.from(me.data()?['followingList'] ?? []);
    return list.contains(targetUid);
  }

  Future<bool> _hasPendingRequest(String fromUid, String toUid) async {
    final snap = await FirebaseFirestore.instance
        .collection("follow_requests")
        .where("from", isEqualTo: fromUid)
        .where("to", isEqualTo: toUid)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text("@${widget.username}")),
      body: FutureBuilder(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found"));
          }

          final doc = snapshot.data!;
          final data = doc.data()!;
          final targetUid = doc.id;

          final bool isOwner = currentUid == targetUid;
          final bool isPrivate = data["isPrivateProfile"] == true;

          // 🔒 PRIVATE PROFILE
          if (isPrivate && !isOwner) {
            return FutureBuilder<bool>(
              future: currentUid == null
                  ? Future.value(false)
                  : _hasPendingRequest(currentUid, targetUid),
              builder: (context, snap) {
                final pending = snap.data == true;

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 64),
                      const SizedBox(height: 12),
                      const Text("This profile is private"),
                      const SizedBox(height: 16),
                      pending
                          ? const Text("Follow request pending")
                          : ElevatedButton(
                        onPressed: currentUid == null
                            ? null
                            : () async {
                          await _userService.sendFollowRequest(
                            currentUid,
                            targetUid,
                          );
                          setState(() {});
                        },
                        child: const Text("Request Follow"),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // ✅ PUBLIC PROFILE
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: (data["photoUrl"] ?? "").isNotEmpty
                      ? NetworkImage(data["photoUrl"])
                      : null,
                  child: (data["photoUrl"] ?? "").isEmpty
                      ? Text(
                    (data["displayName"] ?? "?")[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28),
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  data["displayName"] ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Center(
                child: Text(
                  "@${data["username"]}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 12),

              if (!isOwner && currentUid != null)
                FutureBuilder<bool>(
                  future: _isFollowing(currentUid, targetUid),
                  builder: (context, followSnap) {
                    final following = followSnap.data == true;

                    return ElevatedButton(
                      onPressed: () async {
                        if (following) {
                          await _userService.unfollow(
                              currentUid, targetUid);
                        } else {
                          await _userService.follow(
                              currentUid, targetUid);
                        }
                        setState(() {});
                      },
                      child: Text(following ? "Unfollow" : "Follow"),
                    );
                  },
                ),

              const SizedBox(height: 16),

              Text(
                data["bio"] ?? "",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoBox("Followers", data["followers"] ?? 0),
                  _infoBox("Following", data["following"] ?? 0),
                  _infoBox("AR Spots", data["arSpotsCount"] ?? 0),
                ],
              ),

              const SizedBox(height: 24),

              // 🏆 Achievements
              if ((data["achievements"] ?? []).isNotEmpty) ...[
                const Text(
                  "Achievements",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List<String>.from(data["achievements"])
                      .take(6)
                      .map(
                        (a) => Chip(
                      label: Text(a),
                      avatar: const Icon(Icons.emoji_events,
                          size: 16),
                    ),
                  )
                      .toList(),
                ),
              ],

              const SizedBox(height: 24),

              // 🔥 Profile Completion
              if (data["profileCompletion"] != null) ...[
                const Text(
                  "Profile Completion",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (data["profileCompletion"] ?? 0) / 100,
                ),
                const SizedBox(height: 6),
                Text("${data["profileCompletion"]}% completed"),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _infoBox(String label, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
