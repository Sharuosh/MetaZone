// File: lib/screens/home/profile/follow_requests_screen.dart
// MetaZone — Follow Requests Inbox (Realtime • Secure • Clean)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/theme.dart';
import '../../../services/user_service.dart';

class FollowRequestsScreen extends StatefulWidget {
  const FollowRequestsScreen({super.key});

  @override
  State<FollowRequestsScreen> createState() => _FollowRequestsScreenState();
}

class _FollowRequestsScreenState extends State<FollowRequestsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _userService = UserService();

  String get _uid => _auth.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _requestsStream() {
    return _firestore
        .collection("follow_requests")
        .where("to", isEqualTo: _uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> _getUser(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    return doc.data();
  }

  // =====================================================
  // ACCEPT FOLLOW REQUEST
  // + Achievements
  // + Profile Completion
  // =====================================================
  Future<void> _accept(String requestId, String fromUid) async {
    await _userService.acceptFollowRequest(
      requestId,
      fromUid,
      _uid,
    );

    // 🔥 Update achievements for both users
    await _userService.checkAndGrantAchievements(fromUid);
    await _userService.checkAndGrantAchievements(_uid);

    // 🔥 Update profile completion for both users
    await _userService.updateProfileCompletion(fromUid);
    await _userService.updateProfileCompletion(_uid);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Follow request accepted")),
      );
    }
  }

  Future<void> _reject(String requestId) async {
    await _firestore.collection("follow_requests").doc(requestId).delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Follow request rejected")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Follow Requests"),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _requestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No follow requests",
                style: AppTextStyles.caption(),
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final req = requests[index];
              final fromUid = req["from"] as String;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUser(fromUid),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return _loadingTile();
                  }

                  final user = userSnap.data!;
                  final name = user["displayName"] ?? "Unknown";
                  final username = user["username"] ?? "";
                  final avatar = user["photoUrl"] ?? "";

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                          avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          child: avatar.isEmpty
                              ? Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 18),
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.title(size: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "@$username",
                                style: AppTextStyles.caption(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon:
                          const Icon(Icons.close, color: Colors.redAccent),
                          onPressed: () => _reject(req.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check,
                              color: Colors.greenAccent),
                          onPressed: () => _accept(req.id, fromUid),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _loadingTile() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
