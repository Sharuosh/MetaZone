// lib/screens/home/chat/private_chats.dart
// MetaZone — Private Chats (Production Backend Connected)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../services/chat_service.dart';

import 'chat_screen.dart';
import 'user_profile_popup.dart';

class PrivateChats extends StatefulWidget {
  const PrivateChats({super.key});

  @override
  State<PrivateChats> createState() => _PrivateChatsState();
}

class _PrivateChatsState extends State<PrivateChats>
    with TickerProviderStateMixin {
  final TextEditingController _searchCtl = TextEditingController();
  final ChatService _chatService = ChatService();

  late AnimationController _glowCtrl;

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _filtered = [];

  bool firestoreFailed = false;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);


  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  // ==============================
  // LOCAL PLACEHOLDER (INTENTIONAL)
  // ==============================
  void _loadLocalFallback() {
    _conversations = [
      {
        "name": "Meta Bot",
        "last": "Start a private conversation ✨",
        "time": "now",
        "unread": 0,
        "online": true,
        "avatar": null,
        "userId": "meta_bot",
      }
    ];
    _filtered = List.from(_conversations);
    setState(() {});
  }

  String _fmtTime(dynamic ts) {
    if (ts is! Timestamp) return "";
    final d = ts.toDate();
    final diff = DateTime.now().difference(d);

    if (diff.inMinutes < 1) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return "${diff.inDays}d";
  }

  // ==============================
  // SEARCH
  // ==============================
  void _onSearch(String q) {
    final t = q.trim().toLowerCase();

    if (t.isEmpty) {
      setState(() => _filtered = List.from(_conversations));
      return;
    }

    setState(() {
      _filtered = _conversations.where((c) {
        return c["name"].toLowerCase().contains(t) ||
            c["last"].toLowerCase().contains(t);
      }).toList();
    });
  }

  // ==============================
  // OPEN PRIVATE CHAT (REAL BACKEND)
  // ==============================
  Future<void> _openChat(Map c) async {
    final otherUserId = c["userId"];
    if (otherUserId == null || otherUserId.isEmpty) return;

    final ctx = await _chatService.getPrivateContext(otherUserId);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          contextType: "PRIVATE",
          contextId: ctx.id,
          contextName: c["name"],
        ),
      ),
    );
  }

  // ==============================
  // PROFILE POPUP
  // ==============================
  void _openProfile(Map c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UserProfilePopup(
        userId: c["userId"] ?? "",
        userName: c["name"],
        avatarUrl: c["avatar"],
      ),
    );
  }

  // ==============================
  // AVATAR + ONLINE GLOW
  // ==============================
  Widget _avatar(Map u) {
    return GestureDetector(
      onTap: () => _openProfile(u),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, child) {
              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: u["online"]
                      ? [
                    BoxShadow(
                      color: AppColors.primary
                          .withOpacity(.45 * _glowCtrl.value),
                      blurRadius: 12,
                    )
                  ]
                      : [],
                ),
                child: child,
              );
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.cardSoft,
              backgroundImage:
              u["avatar"] != null ? NetworkImage(u["avatar"]) : null,
              child: u["avatar"] == null
                  ? Text(
                u["name"][0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
          ),
          if (u["online"])
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==============================
  // CHAT TILE
  // ==============================
  Widget _chatTile(Map u) {
    return GestureDetector(
      onTap: () => _openChat(u),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
        ),
        child: Row(
          children: [
            _avatar(u),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u["name"],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u["last"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                    TextStyle(color: AppColors.textSoft, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  u["time"],
                  style: TextStyle(
                      color: AppColors.textLight, fontSize: 11),
                ),
                if (u["unread"] > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${u["unread"]}",
                      style: const TextStyle(
                          color: Colors.black, fontSize: 11),
                    ),
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  // ==============================
  // BUILD
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          "Private Messages",
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _searchCtl,
              onChanged: _onSearch,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: "Search conversations…",
                hintStyle: TextStyle(color: AppColors.textSoft),
                filled: true,
                fillColor: AppColors.cardSoft,
                prefixIcon:
                Icon(Icons.search, color: AppColors.textSoft),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.privateConversationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No conversations",
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                  );
                }

                _conversations = snapshot.data!;
                _filtered = _conversations;

                return ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _chatTile(_filtered[i]),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
