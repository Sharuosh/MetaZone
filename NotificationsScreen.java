import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// الثيم الموحد
import '../../../core/theme/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ================================
  //   MOCK DATA (قابلة للتوصيل بأي API لاحقاً)
  // ================================
  List<Map<String, dynamic>> _notifications = [
    {
      "id": "notif1",
      "title": "New AR Spot Discovered Near You",
      "body": "‘Nebula Gate’ is now visible 120m away.",
      "type": "ar_spot",
      "time": "2m ago",
      "read": false,
    },
    {
      "id": "notif2",
      "title": "AR Object Interacted",
      "body": "Someone interacted with your AR object ‘HoloBench’.",
      "type": "ar_object",
      "time": "12m ago",
      "read": false,
    },
    {
      "id": "notif3",
      "title": "New Message in Global Chat",
      "body": "Nova: \"Anyone found the new portal?\"",
      "type": "chat",
      "time": "25m ago",
      "read": true,
    },
    {
      "id": "notif4",
      "title": "Daily Mission Updated",
      "body": "Complete: Find the ‘Sky Lantern’ AR spot.",
      "type": "mission",
      "time": "1h ago",
      "read": true,
    },
    {
      "id": "notif5",
      "title": "Reward Unlocked",
      "body": "+15 XP for your recent AR activity.",
      "type": "reward",
      "time": "3h ago",
      "read": false,
    },
    {
      "id": "notif6",
      "title": "System Update",
      "body": "New AR rendering patch installed.",
      "type": "system",
      "time": "5h ago",
      "read": true,
    },
  ];

  // ================================
  //   ICONS + COLORS PER NOTIF TYPE
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
  //   ACTIONS
  // ================================
  void _markAsRead(String id) {
    setState(() {
      final i = _notifications.indexWhere((n) => n["id"] == id);
      if (i != -1) _notifications[i]["read"] = true;
    });
  }

  void _delete(String id) {
    setState(() {
      _notifications.removeWhere((n) => n["id"] == id);
    });
  }

  // ================================
  //   UI
  // ================================
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              setState(() {
                for (var n in _notifications) n["read"] = true;
              });
            },
            child: const Text("Mark all as read",
                style: TextStyle(color: AppColors.textSoft)),
          )
        ],
      ),

      body: _notifications.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _notifications.length,
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return _notificationTile(n);
              },
            ),
    );
  }

  Widget _notificationTile(Map<String, dynamic> n) {
    return Dismissible(
      key: Key(n["id"]),
      background: _swipeBg(AppColors.primary, Icons.check, "Mark read"),
      secondaryBackground:
          _swipeBg(Colors.redAccent, Icons.delete, "Delete"),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _markAsRead(n["id"]);
          return false;
        } else {
          _delete(n["id"]);
          return true;
        }
      },
      child: GestureDetector(
        onTap: () => _markAsRead(n["id"]),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n["read"] ? AppColors.surface : AppColors.card,
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
                      n["title"],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n["body"],
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n["time"],
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!n["read"])
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
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
          const Text(
            "No notifications yet",
            style: TextStyle(color: AppColors.textSoft, fontSize: 16),
          )
        ],
      ),
    );
  }
}
