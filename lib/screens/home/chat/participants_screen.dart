// lib/screens/home/chat/participants_screen.dart
// MetaZone – Participants (Realtime • Firestore • Presence • Roles)

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'chat_screen.dart';
import 'user_profile_popup.dart';

class ParticipantsScreen extends StatelessWidget {
  final String roomId;

  const ParticipantsScreen({
    super.key,
    required this.roomId,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> _membersStream() {
    return FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(roomId)
        .collection("members")
        .orderBy("role", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          "Participants",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _membersStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No members yet",
                style: TextStyle(color: AppColors.textSoft),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data();
              return _memberTile(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _memberTile(BuildContext context, Map<String, dynamic> m) {
    final username = m["username"] ?? "User";
    final userId = m["uid"];
    final role = m["role"] ?? "member";
    final online = m["online"] ?? false;

    return GestureDetector(
      onTap: () => _openUserPopup(context, username, userId),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.cardSoft,
              child: Text(
                username[0].toUpperCase(),
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(username,
                          style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      _roleChip(role),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    online ? "Online" : "Offline",
                    style: TextStyle(
                      color: online
                          ? Colors.greenAccent
                          : AppColors.textSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => _openChat(context, userId, username),
              icon: Icon(Icons.chat_outlined, color: AppColors.primary),
            )
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String r) {
    Color c;

    switch (r) {
      case "owner":
        c = Colors.amberAccent;
        break;
      case "admin":
        c = AppColors.primary;
        break;
      default:
        c = AppColors.textSoft;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c),
      ),
      child: Text(
        r.toUpperCase(),
        style: TextStyle(fontSize: 10, color: c),
      ),
    );
  }

  void _openUserPopup(BuildContext context, String username, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UserProfilePopup(
        userId: userId,
        userName: username,
      ),
    );
  }

  void _openChat(BuildContext context, String userId, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: userId,
          roomName: username,
        ),
      ),
    );
  }
}
