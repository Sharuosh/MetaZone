import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Theme
import '../../../../core/theme/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ================================
  // ICONS + COLORS PER NOTIF TYPE
  // ================================
  IconData _iconForType(String t) {
    switch (t) {
      case "ar_spot":
        return Icons.location_on_rounded;
      case "ar_object":
        return Icons.view_in_ar;
      case "chat":
        return Icons.chat_bubble_rounded;
      case "mission":
        return Icons.flag_rounded;
      case "reward":
        return Icons.stars_rounded;
      case "system":
      default:
        return Icons.info_rounded;
    }
  }

  Color _iconColor(String t) {
    switch (t) {
      case "reward":
        return AppColors.primary;
      case "system":
        return AppColors.textSoft;
      default:
        return AppColors.primarySoft;
    }
  }

  // ================================
  // ACTIONS (REAL BACKEND)
  // ================================
  Future<void> _markAsRead(DocumentReference ref) async {
    await ref.update({"read": true});
  }

  Future<void> _delete(DocumentReference ref) async {
    await ref.delete();
  }

  Future<void> _markAllAsRead() async {
    final uid = _auth.currentUser!.uid;
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    for (final d in snap.docs) {
      d.reference.update({'read': true});
    }
  }

  // ================================
  // UI
  // ================================
  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Notifications",
          style: GoogleFonts.orbitron(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              "Mark all as read",
              style: TextStyle(color: AppColors.textSoft),
            ),
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final n = doc.data() as Map<String, dynamic>;
              return _notificationTile(n, doc.reference);
            },
          );
        },
      ),
    );
  }

  // ================================
  // NOTIFICATION TILE
  // ================================
  Widget _notificationTile(
      Map<String, dynamic> n,
      DocumentReference ref,
      ) {
    final bool isRead = n["read"] == true;

    return Dismissible(
      key: Key(ref.id),
      background: _swipeBg(AppColors.primary, Icons.check, "Mark read"),
      secondaryBackground:
      _swipeBg(Colors.redAccent, Icons.delete, "Delete"),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _markAsRead(ref);
          return false;
        } else {
          await _delete(ref);
          return true;
        }
      },
      child: GestureDetector(
        onTap: () => _markAsRead(ref),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? AppColors.surface : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primarySoft.withOpacity(.20),
                child: Icon(
                  _iconForType(n["type"]),
                  size: 22,
                  color: _iconColor(n["type"]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n["title"] ?? "",
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n["body"] ?? "",
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n["timeLabel"] ?? "",
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration:  BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // ================================
  // HELPERS
  // ================================
  Widget _swipeBg(Color c, IconData icon, String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: c.withOpacity(.25)),
      child: Row(
        children: [
          Icon(icon, color: c),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: c)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none,
              color: AppColors.textSoft, size: 58),
          const SizedBox(height: 12),
          Text(
            "No notifications yet",
            style: TextStyle(color: AppColors.textSoft, fontSize: 16),
          )
        ],
      ),
    );
  }
}
