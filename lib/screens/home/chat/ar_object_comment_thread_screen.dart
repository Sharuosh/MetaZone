import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../services/chat_service.dart';

class ARObjectCommentThreadScreen extends StatefulWidget {
  final String contextId;        // AR Object Context ID
  final String objectName;       // Object display name
  final String parentMessageId;  // Root comment ID

  const ARObjectCommentThreadScreen({
    super.key,
    required this.contextId,
    required this.objectName,
    required this.parentMessageId,
  });

  @override
  State<ARObjectCommentThreadScreen> createState() =>
      _ARObjectCommentThreadScreenState();
}

class _ARObjectCommentThreadScreenState
    extends State<ARObjectCommentThreadScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _replyCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _sending = false;

  // =============================
  // SEND REPLY (THREAD)
  // =============================
  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    _chatService.sendTextMessage(
      contextType: 'AR_OBJECT',
      contextId: widget.contextId,
      text: text,
      parentMessageId: widget.parentMessageId, // 🧵 Threaded reply

    );


    _replyCtrl.clear();
    setState(() => _sending = false);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // =============================
  // BUILD
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          "Replies • ${widget.objectName}",
          style: GoogleFonts.inter(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // =============================
          // THREAD LIST
          // =============================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chat_contexts')
                  .doc(widget.contextId)
                  .collection('messages')
                  .where(
                'parentMessageId',
                isEqualTo: widget.parentMessageId,
              )
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No replies yet",
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(14),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data();
                    final sender = data['sender'] ?? {};
                    final isAnon = sender['isAnonymous'] == true;
                    final name =
                    isAnon ? sender['alias'] : "User";
                    final text = data['payload']?['text'] ?? "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border.withOpacity(.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            text,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // =============================
          // INPUT BAR
          // =============================
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: "Write a reply…",
                      hintStyle: TextStyle(color: AppColors.textSoft),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: _sending
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sending ? null : _sendReply,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
