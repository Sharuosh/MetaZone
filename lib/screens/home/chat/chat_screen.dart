// lib/screens/home/chat/chat_screen.dart
// MetaZone — Unified Chat (GLOBAL • NEARBY • AR_OBJECT • PRIVATE)

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/theme.dart';
import '../../../services/chat_service.dart';

import 'sticker_picker.dart';
import 'ar_object_comment_thread_screen.dart';



class ChatScreen extends StatefulWidget {
  final String contextId;   // ID الحقيقي (arObjectId / userId / global)
  final String contextName; // الاسم اللي يظهر فوق
  final String contextType; // GLOBAL | NEARBY | AR_OBJECT | PRIVATE

  const ChatScreen({
    super.key,
    required this.contextId,
    required this.contextName,
    required this.contextType,

  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  Timer? _heartbeatTimer;
  bool _markedSeenOnce = false;
  late final String _ctxId;
  bool _initialized = false;
  bool _sending = false;


  void _markSeen() async {
    try {
      await _chatService.markChatSeen(
        contextType: widget.contextType,
        contextId: _ctxId,
      );
    } catch (_) {}
  }



  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFollowing = false;

  final ChatService _chatService = ChatService();
  Stream<int> _onlineCountStream() {
    return FirebaseFirestore.instance
        .collection('chat_contexts')
        .doc(_ctxId)

        .collection('participants')
        .where(
      'lastActiveAt',
      isGreaterThan: Timestamp.fromDate(
        DateTime.now().subtract(const Duration(seconds: 20)),
      ),
    )
        .snapshots()
        .map((s) => s.size);
  }

  bool _showJumpBtn = false;

  Map<String, dynamic>? _replyTo;
  @override
  void initState() {
    super.initState();

    if (_initialized) return;
    _initialized = true;

    _ctxId = _chatService.ctx(
      widget.contextType,
      widget.contextId,
    );

    assert(
    widget.contextType != "AR_OBJECT" || widget.contextId.isNotEmpty,
    "AR Object chat لازم يكون له objectId",
    );

    _markedSeenOnce = false;

    if (widget.contextType == "AR_OBJECT") {
      _chatService.isFollowingARObject(widget.contextId).then((v) {
        if (mounted) setState(() => _isFollowing = v);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (widget.contextType != "PRIVATE") {
          await _chatService.joinContext(
            widget.contextType,
            widget.contextId,
          );

          _heartbeatTimer = Timer.periodic(
            const Duration(seconds: 10),
                (_) => _chatService.sendHeartbeat(_ctxId),
          );
        }

      } catch (e) {
        debugPrint("Join context failed: $e");
      }
    });
    _scrollController.addListener(_handleScroll);

  }



  void _handleScroll() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 200) {
      if (_showJumpBtn) setState(() => _showJumpBtn = false);
    } else {
      if (!_showJumpBtn) setState(() => _showJumpBtn = true);
    }
  }



  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _scrollController.removeListener(_handleScroll);

    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

    // =============================
  // SEND MESSAGE (ChatService)
  // =============================
  Future<void> _sendMessage({String? sticker}) async {
    if (_sending) return;

    final text = (sticker ?? _msgController.text).trim();
    if (text.isEmpty) return;

    _sending = true;

    try {
      await _chatService.sendTextMessage(
        contextType: widget.contextType,
        contextId: widget.contextId,
        text: text,
        parentMessageId: _replyTo?['id'],
      );

      if (!mounted) return;

      _msgController.clear();
      FocusScope.of(context).unfocus();
      _replyTo = null;

      _scrollToBottom();
    } catch (e) {
      debugPrint("❌ Send message failed: $e");
    } finally {
      _sending = false;
    }
  }


  // =============================
  // SCROLL
  // =============================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 300,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // =============================
  // REPLY PREVIEW
  // =============================
  Widget _replyPreview() {
    if (_replyTo == null) return const SizedBox();
    final s = _replyTo!['sender'] ?? {};
    final isMe =
        s['userId'] != null &&
            s['userId'] == _chatService.currentUserId;

    final replyName = isMe
        ? "You"
        : (s['isAnonymous'] == true ? s['alias'] ?? "User" : "User");


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.6),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  replyName,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),


                const SizedBox(height: 4),
                Text(
                  _replyTo!['payload']?['text'] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _replyTo = null),
            child: Icon(Icons.close, color: AppColors.textSoft),
          )
        ],
      ),
    );
  }

  // =============================
  // MESSAGE BUBBLE
  // =============================
  Widget _bubble(Map<String, dynamic> msg) {
    final sender = msg['sender'] ?? {};
    final isAnonymous = sender['isAnonymous'] == true;

    // 👈 هل الرسالة منّي؟
    final isMe =
        sender['userId'] != null &&
            sender['userId'] == _chatService.currentUserId;

    final name = isAnonymous
        ? sender['alias']
        : isMe
        ? "You"
        : "User";

    final text = msg['payload']?['text'] ?? "";
    final tsRaw = msg['createdAt'];
    final ts = tsRaw is Timestamp
        ? tsRaw.toDate()
        : DateTime.now();
    final time =
        "${ts.hour}:${ts.minute.toString().padLeft(2, '0')}";



    return GestureDetector(
      onLongPress: () => setState(() => _replyTo = msg),
      child: Align(
        alignment:
        isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .75,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.primary.withOpacity(.15)
                : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isMe
                  ? AppColors.primary.withOpacity(.4)
                  : AppColors.border.withOpacity(.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color:
                  isMe ? AppColors.primary : AppColors.textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                ),
              ),
              if (msg['reactions'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    children: (msg['reactions'] as Map<String, dynamic>).entries
                        .where((e) => (e.value as List).isNotEmpty)
                        .map((e) => GestureDetector(
                      onTap: () => _chatService.toggleReaction(
                        contextId: _ctxId,
                        messageId: msg['id'],
                        emoji: e.key,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('${e.key} ${e.value.length}'),
                      ),
                    ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // =============================
  // INPUT BAR
  // =============================
  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _replyPreview(),

          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(.45),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withOpacity(.45),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _openStickers,
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: AppColors.primary,
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        minLines: 1,
                        maxLines: 4,
                        onChanged: (_) {

                        },
                        style: TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          hintText: "Write a comment…",
                          hintStyle:
                          TextStyle(color: AppColors.textSoft),
                          filled: true,
                          fillColor:
                          AppColors.card.withOpacity(.3),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Material(
                      color: Colors.transparent,
                      child: InkResponse(
                        radius: 28,
                        onTap: _sendMessage,
                        splashColor: AppColors.primary.withOpacity(.3),
                        highlightColor: AppColors.primary.withOpacity(.15),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // =============================
  // STICKERS
  // =============================
  void _openStickers() async {
    final sticker = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      builder: (_) => const StickerPicker(),
    );

    if (sticker != null) _sendMessage(sticker: sticker);
  }


  // =============================
  // BUILD
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _showJumpBtn
          ? FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        onPressed: _scrollToBottom,
        child:
        const Icon(Icons.arrow_downward, color: Colors.black),
      )
          : null,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.contextName,
            style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600)),
        actions: [
          if (widget.contextType == "AR_OBJECT")
            IconButton(
              icon: Icon(
                _isFollowing ? Icons.star : Icons.star_border,
                color: _isFollowing ? Colors.amber : AppColors.textSoft,
              ),
              onPressed: () async {
                if (_isFollowing) {
                  await _chatService.unfollowARObject(widget.contextId);
                } else {
                  await _chatService.followARObject(widget.contextId);
                }
                setState(() => _isFollowing = !_isFollowing);
              },
            ),

          if (widget.contextType != "AR_OBJECT")
            StreamBuilder<int>(
              stream: _onlineCountStream(),

            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    "${snap.data} online",
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],

      ),

      body: Column(
        children: [


          Expanded(
            child: StreamBuilder(
              stream: _chatService.messagesStream(
                contextType: widget.contextType,
                contextId: _ctxId,
              ),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final data = snap.data!.docs.reversed.map((e) {
                  final d = e.data();
                  d['id'] = e.id;
                  return d;
                })
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_markedSeenOnce) {
                    _markSeen();
                    _markedSeenOnce = true;
                  }
                });

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding:
                  const EdgeInsets.only(top: 8, bottom: 12),
                  itemCount: data.length,
                  itemBuilder: (_, i) => _bubble(data[i]),

                );
              },
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }
}
