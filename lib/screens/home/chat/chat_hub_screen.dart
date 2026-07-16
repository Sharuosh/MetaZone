// lib/screens/home/chat/chat_hub_screen.dart
// MetaZone — Chat Hub (Production Ready – Future AR Ready)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';

// SUB SCREENS
import 'nearby_chats.dart';
import 'ar_objects_chats.dart';
import 'private_chats.dart';
import 'global_chat.dart';

class ChatHubScreen extends StatefulWidget {
  const ChatHubScreen({super.key});

  @override
  State<ChatHubScreen> createState() => _ChatHubScreenState();
}

class _ChatHubScreenState extends State<ChatHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  int unreadGlobal = 0;
  int unreadPrivate = 0;
  int unreadNearby = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);

    _listenUnreadCounters();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // LISTEN — unread indicators
  void _listenUnreadCounters() {
    try {
      FirebaseFirestore.instance
          .collection("global_chat")
          .where("read", isEqualTo: false)
          .snapshots()
          .listen((s) {
        setState(() => unreadGlobal = s.docs.length);
      });

      FirebaseFirestore.instance
          .collection("private_chats_meta")
          .where("unread", isEqualTo: true)
          .snapshots()
          .listen((s) {
        setState(() => unreadPrivate = s.docs.length);
      });

      FirebaseFirestore.instance
          .collection("nearby_chat_rooms")
          .snapshots()
          .listen((s) {
        setState(() => unreadNearby = s.docs.length);
      });
    } catch (_) {
      // silent fallback – works even if Firestore not ready
    }
  }

  // ========= QUICK NEW CHAT ==========
  void _openCreateChatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, color: AppColors.cardSoft),
              const SizedBox(height: 12),
              Text("Start Conversation",
                  style: AppTextStyles.title(size: 16)),
              const SizedBox(height: 10),

              _actionTile(Icons.person, "Private Chat", "Direct secure DM", () {
                Navigator.pop(context);
              }),

              _actionTile(Icons.language, "Global Room",
                  "Message everyone in MetaZone", () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const GlobalChatScreen()));
                  }),

              _actionTile(Icons.location_on, "Nearby Chat",
                  "Talk to users around you", () {
                    Navigator.pop(context);
                  }),

              _actionTile(Icons.view_in_ar, "AR Object Chat",
                  "Chat tied to AR content", () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        );
      },
    );
  }

  Widget _actionTile(
      IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading:
      Icon(icon, color: AppColors.primary, size: 26),
      title: Text(title, style: AppTextStyles.title(size: 14)),
      subtitle: Text(sub, style: AppTextStyles.caption()),
      trailing: Icon(Icons.chevron_right, color: AppColors.textSoft),
    );
  }

  Widget _badge(int n) {
    if (n == 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text("$n",
          style:
          const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        onPressed: _openCreateChatSheet,
        child: const Icon(Icons.add_comment_rounded),
      ),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AppBar(
              elevation: 0,
              backgroundColor: AppColors.card.withOpacity(.55),

              title: Text(
                "MetaZone Chat",
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              bottom: TabBar(
                controller: _tab,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSoft,
                indicator: BoxDecoration(
                  color: AppColors.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                tabs: [
                  Tab(
                    text: "Nearby",
                    iconMargin: EdgeInsets.zero,
                    icon: _badge(unreadNearby),
                  ),
                  const Tab(text: "AR Objects"),
                  Tab(
                    text: "Private",
                    icon: _badge(unreadPrivate),
                  ),
                  Tab(
                    text: "Global",
                    icon: _badge(unreadGlobal),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tab,
        physics: const BouncingScrollPhysics(),
        children: const [
          NearbyChats(),
          ARObjectsChats(),
          PrivateChats(),
          GlobalChatScreen(),
        ],
      ),
    );
  }
}
