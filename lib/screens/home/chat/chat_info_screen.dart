// lib/screens/home/chat/chat_info_screen.dart
// MetaZone — Chat Info (Stable • Null-Safe • AR Neon UI)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import 'shared_media_screen.dart';
import 'user_profile_popup.dart';

class ChatInfoScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatInfoScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  bool _muted = false;
  bool _blocked = false;

  late Map<String, dynamic> room;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  void _loadRoom() {
    room = {
      "id": widget.roomId,
      "name": widget.roomName,
      "image": "https://picsum.photos/seed/${widget.roomId}/600/400",
      "description":
      "A futuristic AR-powered chat room synced with real world locations.",
      "followers": 432,
      "active": 12,
      "createdAt": "Jan 2025",
      "type": "AR Portal",
      "members": [
        {"name": "Lina", "online": true},
        {"name": "Omar", "online": false},
        {"name": "MetaBot", "online": true},
        {"name": "Explorer_21", "online": false},
      ],
      "media": [
        "https://picsum.photos/seed/m1/600/500",
        "https://picsum.photos/seed/m2/600/500",
        "https://picsum.photos/seed/m3/600/500"
      ],
      "pinned": [
        {"text": "Welcome to the portal! 🚀"},
        {"text": "AR event at 6pm today 🔥"},
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    final members =
    List<Map<String, dynamic>>.from((room["members"] ?? []) as List);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Chat Info",
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _roomHeader(),
          const SizedBox(height: 20),
          _stats(),
          const SizedBox(height: 20),
          _section("Pinned Messages"),
          _pinned(),
          const SizedBox(height: 20),
          _section("Members (${members.length})"),
          _members(),
          const SizedBox(height: 20),
          _section("Shared Media"),
          _media(),
          const SizedBox(height: 20),
          _section("Settings"),
          _settings(),
          const SizedBox(height: 26),
        ],
      ),
    );
  }

  // HEADER
  Widget _roomHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(.35)),
          ),
          child: Row(
            children: [
              Hero(
                tag: "room_${room["id"]}",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    room["image"],
                    height: 82,
                    width: 82,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room["name"], style: AppTextStyles.title(size: 18)),
                    const SizedBox(height: 8),
                    Text(
                      room["description"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(),
                    ),
                    const SizedBox(height: 12),
                    _chip(room["type"]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STATS
  Widget _stats() {
    return Container(
      decoration: _box(),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(Icons.people, "${room["followers"]}", "Followers"),
          _divider(),
          _stat(Icons.visibility, "${room["active"]}", "Active"),
          _divider(),
          _stat(Icons.calendar_month, room["createdAt"], "Created"),
        ],
      ),
    );
  }

  Widget _stat(IconData i, String v, String t) {
    return Column(
      children: [
        Icon(i, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(v, style: AppTextStyles.title(size: 14)),
        Text(t, style: AppTextStyles.caption()),
      ],
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: AppColors.border.withOpacity(.4),
  );

  // PINNED
  Widget _pinned() {
    final pinned =
    List<Map<String, dynamic>>.from((room["pinned"] ?? []) as List);

    return Container(
      decoration: _box(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: pinned
            .map(
              (p) => Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(.35),
              ),
              color: AppColors.card.withOpacity(.3),
            ),
            child: Row(
              children: [
                Icon(Icons.push_pin, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p["text"] ?? "",
                    style: AppTextStyles.body(size: 14),
                  ),
                )
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  // MEMBERS
  Widget _members() {
    final members =
    List<Map<String, dynamic>>.from((room["members"] ?? []) as List);

    return Container(
      decoration: _box(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: members.map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => UserProfilePopup(
                        userId: m["name"],
                        userName: m["name"],
                        avatarUrl: null,
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.cardSoft,
                    child: Text(
                      (m["name"] ?? "?")[0],
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m["name"] ?? "",
                    style: AppTextStyles.title(size: 14),
                  ),
                ),
                Text(
                  (m["online"] ?? false) ? "Online" : "Offline",
                  style: TextStyle(
                    color: (m["online"] ?? false)
                        ? Colors.greenAccent
                        : AppColors.textSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // MEDIA
  Widget _media() {
    final media = List<String>.from((room["media"] ?? []) as List);

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final url = media[i];
          return Hero(
            tag: url,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => SharedMediaScreen(
                      username: room["name"],
                      userId: room["id"],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, width: 140, fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  // SETTINGS
  Widget _settings() {
    return Container(
      decoration: _box(),
      child: Column(
        children: [
          _setting(
            "Mute Notifications",
            Icons.volume_off,
            toggle: true,
            value: _muted,
            onTap: () => setState(() => _muted = !_muted),
          ),
          _line(),
          _setting(
            "Block Room",
            Icons.block,
            toggle: true,
            value: _blocked,
            onTap: () => setState(() => _blocked = !_blocked),
          ),
          _line(),
          _setting("Clear Chat History", Icons.delete_forever,
              color: Colors.redAccent),
          _line(),
          _setting("Leave Room", Icons.logout, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _setting(
      String t,
      IconData i, {
        VoidCallback? onTap,
        bool toggle = false,
        bool value = false,
        Color? color,
      }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(i, color: color ?? AppColors.primary),
      title: Text(
        t,
        style: TextStyle(
          color: color ?? AppColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: toggle
          ? Switch(
        value: value,
        onChanged: (_) => onTap?.call(),
        activeColor: AppColors.primary,
      )
          : null,
    );
  }

  Widget _chip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.card.withOpacity(.4),
        border: Border.all(color: AppColors.primary.withOpacity(.35)),
      ),
      child: Text(
        t,
        style: AppTextStyles.caption(size: 12),
      ),
    );
  }

  Widget _line() => Container(
    height: 1,
    color: AppColors.border.withOpacity(.45),
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );

  BoxDecoration _box() {
    return BoxDecoration(
      color: AppColors.card.withOpacity(.45),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border.withOpacity(.5)),
    );
  }

  Widget _section(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: AppTextStyles.title(size: 16),
      ),
    );
  }
}
