// File: lib/screens/home/chat/global_chat.dart
// MetaZone — Global Chat (Production-grade, Firestore-authenticated, anti-spam, XP Ranks)

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../../../services/chat_service.dart';
import 'chat_screen.dart';


class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({super.key});

  final bool useFirestore = true;

  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focus = FocusNode();
  String? _globalContextId;

  bool _sending = false;
  bool _isTyping = false;
  bool _failedToInitFirestore = false;


  final List<Map<String, dynamic>> _localMessages = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _fsSub;

  DateTime? _lastMsg; // Anti-spam throttle

  @override
  void initState() {
    super.initState();
    _initGlobalContext();
  }

  @override
  void dispose() {
    _fsSub?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }
  Future<void> _initGlobalContext() async {
    try {
      final ctxRef = await ChatService().getGlobalContext();
      _globalContextId = ctxRef.id;

      await ChatService().joinContext(
        "GLOBAL",
        _globalContextId!,
      );

      _startFirestore();
    } catch (e) {
      _failedToInitFirestore = true;
      _seedLocal();
    }
  }


  // ---------------- Local fallback ----------------
  void _seedLocal() {
    _localMessages.clear();
    _localMessages.addAll([
      _makeLocalMsg("MetaBot", "Welcome to MetaZone Global! 🌐"),
      _makeLocalMsg("Explorer_01", "Anyone saw the new portal near Nile?"),
      _makeLocalMsg("Nova", "Sharing a cool placement!"),
    ]);
    setState(() {});
  }

  Map<String, dynamic> _makeLocalMsg(String user, String text) {
    return {
      "docId": DateTime.now().microsecondsSinceEpoch.toString(),
      "user": user,
      "text": text,
      "createdAt": Timestamp.fromDate(DateTime.now()),
      "colorHex": AppColors.text.value,
      "xp": 10,
      "reactions": <String, int>{},
    };
  }

  // ---------------- Firestore ----------------
  void _startFirestore() {
    if (_globalContextId == null) return;

    try {
      final col = FirebaseFirestore.instance
          .collection("chat_contexts")
          .doc(_globalContextId)
          .collection("messages")
          .orderBy("createdAt", descending: false)
          .limitToLast(500);

      _fsSub = col.snapshots().listen((snap) {
        final docs = snap.docs.map((d) {
          final data = d.data();
          data["docId"] = d.id;

          // توحيد شكل الرسالة مع UI
          final sender = data["sender"] ?? {};
          data["user"] = sender["alias"] ??
              sender["userId"] ??
              "User";
          data["text"] = data["payload"]?["text"] ?? "";

          return data;
        }).toList();

        _replaceLocalWith(docs);
      }, onError: (_) {
        _failedToInitFirestore = true;
        _seedLocal();
      });
    } catch (_) {
      _failedToInitFirestore = true;
      _seedLocal();
    }
  }


  void _replaceLocalWith(List<Map<String, dynamic>> docs) {
    _localMessages
      ..clear()
      ..addAll(docs);
    setState(() {});
    _scrollToBottom(animated: false);
  }

  // ---------------- Send Message ----------------
  Future<void> _sendMessage({String? text}) async {
    final body = (text ?? _inputCtrl.text).trim();
    if (body.isEmpty) return;

    // anti-spam (2 seconds)
    if (_lastMsg != null &&
        DateTime.now().difference(_lastMsg!).inSeconds < 2) {
      return;
    }
    _lastMsg = DateTime.now();

    final user = FirebaseAuth.instance.currentUser;

    _inputCtrl.clear();
    _focus.requestFocus();
    setState(() => _sending = true);

    final msg = {
      "userId": user?.uid ?? "guest",
      "user": (user?.displayName ??
          user?.email?.split("@").first ??
          "Guest")
          .trim(),
      "text": body,
      "createdAt": FieldValue.serverTimestamp(),
      "colorHex": AppColors.primary.value,
      "xp": 1,
      "reactions": <String, int>{},
    };

    if (widget.useFirestore && !_failedToInitFirestore) {
      try {
        await ChatService().sendTextMessage(
          contextType: "GLOBAL",
          contextId: _globalContextId!,
          text: body,
        );
      } catch (_) {
        _addLocalMessage(msg);
      }
    } else {
      _addLocalMessage(msg);
    }

    setState(() => _sending = false);
    _scrollToBottom();
  }

  void _addLocalMessage(Map<String, dynamic> msg) {
    final local = Map<String, dynamic>.from(msg);
    local["docId"] = DateTime.now().microsecondsSinceEpoch.toString();
    local["createdAt"] = Timestamp.fromDate(DateTime.now());
    _localMessages.add(local);
    setState(() {});
  }

  // ---------------- Reactions ----------------
  Future<void> _addReaction(String docId, String emoji) async {
    if (widget.useFirestore && !_failedToInitFirestore) {
      try {
        await FirebaseFirestore.instance
            .collection('messages')

            .doc(docId)
            .set({
          "reactions": {emoji: FieldValue.increment(1)}
        }, SetOptions(merge: true));
        return;
      } catch (_) {}
    }
    _addReactionLocal(docId, emoji);
  }

  void _addReactionLocal(String docId, String emoji) {
    final idx = _localMessages.indexWhere((m) => m["docId"] == docId);
    if (idx == -1) return;
    final reactions =
    Map<String, int>.from(_localMessages[idx]["reactions"] ?? {});
    reactions[emoji] = (reactions[emoji] ?? 0) + 1;
    _localMessages[idx]["reactions"] = reactions;
    setState(() {});
  }

  void _openReactions(Map m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (_) {
        final options = ["❤️", "🔥", "👍", "😂", "🚀"];
        return SizedBox(
          height: 110,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: options.map((e) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _addReaction(m["docId"], e);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ---------------- UI ----------------
  String _rank(int xp) {
    if (xp >= 500) return "HyperPilot";
    if (xp >= 200) return "Meta Rider";
    if (xp >= 50) return "Explorer";
    return "Rookie";
  }

  String _timeLabel(dynamic createdAt) {
    try {
      final ts = createdAt is Timestamp
          ? createdAt
          : Timestamp.fromDate(DateTime.now());
      final dt = ts.toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return "now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m";
      if (diff.inHours < 24) return "${diff.inHours}h";
      return "${diff.inDays}d";
    } catch (_) {
      return "";
    }
  }

  Color _rankColor(String r) {
    switch (r) {
      case "HyperPilot":
        return AppColors.primary;
      case "Meta Rider":
        return AppColors.primarySoft;
      case "Explorer":
        return AppColors.text;
      default:
        return AppColors.textSoft;
    }
  }

  Widget _msgTile(Map m) {
    final user = m["user"] ?? "User";
    final text = m["text"] ?? "";
    final createdAt = m["createdAt"];
    final color =
    m["colorHex"] is int ? Color(m["colorHex"]) : AppColors.text;
    final xp = (m["xp"] is int) ? m["xp"] as int : 0;
    final reactions = Map<String, dynamic>.from(m["reactions"] ?? {});
    final rank = _rank(xp);

    return GestureDetector(
      onLongPress: () => _openReactions(m),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(.14),
              child: Text(
                user.toString().isNotEmpty ? user[0].toUpperCase() : "U",
                style:
                TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(user,
                          style: TextStyle(
                              color: _rankColor(rank),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _rankColor(rank).withOpacity(.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(rank,
                            style: TextStyle(
                                fontSize: 11,
                                color: _rankColor(rank))),
                      ),
                      const Spacer(),
                      Text(
                        _timeLabel(createdAt),
                        style: TextStyle(
                            color: AppColors.textSoft, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(text,
                      style: TextStyle(
                          color: AppColors.textLight, height: 1.35)),
                  if (reactions.isNotEmpty) const SizedBox(height: 8),
                  if (reactions.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: reactions.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.card.withOpacity(.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(e.key),
                                const SizedBox(width: 6),
                                Text("${e.value}",
                                    style: TextStyle(
                                        color: AppColors.textSoft,
                                        fontSize: 12)),
                              ]),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Composer ----------------
  Widget _composer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: _showQuickEmojis,
              icon:
              Icon(Icons.emoji_emotions_outlined, color: AppColors.primary),
            ),
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                focusNode: _focus,
                style: TextStyle(color: AppColors.text),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Send a message… (be kind ✨)",
                  hintStyle: TextStyle(color: AppColors.textSoft),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                onChanged: (_) {
                  if (!_isTyping) {
                    setState(() => _isTyping = true);
                    Future.delayed(
                      const Duration(seconds: 2),
                          () => mounted
                          ? setState(() => _isTyping = false)
                          : null,
                    );
                  }
                },
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _sendMessage(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: _sending
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.background,
                    strokeWidth: 2,
                  ),
                )
                    : Icon(Icons.send, color: AppColors.background),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickEmojis() {
    final list = ["🔥", "🌌", "✨", "🚀", "❤️"];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (_) => SizedBox(
        height: 120,
        child: GridView.builder(
          itemCount: list.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemBuilder: (_, i) {
            final s = list[i];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _sendMessage(text: s);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(s, style: const TextStyle(fontSize: 26)),
              ),
            );
          },
        ),
      ),
    );
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollCtrl.hasClients) return;
      final pos = _scrollCtrl.position.maxScrollExtent;
      animated
          ? _scrollCtrl.animateTo(pos,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut)
          : _scrollCtrl.jumpTo(pos);
    });
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    final msgs = List<Map<String, dynamic>>.from(_localMessages);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          "🌐 Global Chat",
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_failedToInitFirestore)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(child: Text("Offline")),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.isEmpty
                ? Center(
              child: Text("No messages yet",
                  style: TextStyle(color: AppColors.textSoft)),
            )
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              itemCount: msgs.length,
              itemBuilder: (_, i) => _msgTile(msgs[i]),
            ),
          ),
          if (_isTyping)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.edit,
                      size: 16, color: AppColors.textSoft),
                  const SizedBox(width: 6),
                  Text("Someone is typing…",
                      style: TextStyle(color: AppColors.textSoft)),
                ],
              ),
            ),
          _composer(),
        ],
      ),
    );
  }
}
