import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// =======================================================
/// MetaZone Chat Service
/// Core backend engine for ALL chat types:
/// GLOBAL • NEARBY • AR_OBJECT • PRIVATE
/// =======================================================
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _contexts =>
      _db.collection('chat_contexts');

  CollectionReference<Map<String, dynamic>> messagesRef({
    required String contextType,
    required String contextId,
  }) {
    final ctxId = contextType == 'AR_OBJECT'
        ? contextId
        : _contextKey(
      contextType: contextType,
      contextId: contextId,
    );

    return _contexts.doc(ctxId).collection('messages');
  }

  String ctx(String contextType, String contextId) {
    return contextType == 'AR_OBJECT'
        ? contextId
        : _contextKey(
      contextType: contextType,
      contextId: contextId,
    );
  }

  Future<void> toggleReaction({
    required String contextId,
    required String messageId,
    required String emoji,
  }) async {
    if (_auth.currentUser == null) {
      throw StateError('User not authenticated');
    }

    final uid = _currentUserId;
    final ref = _messages(contextId).doc(messageId);
    try {
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data()!;
      final reactions = Map<String, dynamic>.from(
        data['reactions'] ?? {},
      );

      final users = List<String>.from(reactions[emoji] ?? []);

      if (users.contains(uid)) {
        users.remove(uid);
      } else {
        users.add(uid);
      }

      reactions[emoji] = users;

      tx.update(ref, {'reactions': reactions});
    });
    } catch (_) {
      // ignore or log
    }
  }

  CollectionReference<Map<String, dynamic>> _messages(String ctxId) {
    return _contexts.doc(ctxId).collection('messages');
  }

  CollectionReference<Map<String, dynamic>> _participants(String ctxId) {
    return _contexts.doc(ctxId).collection('participants');
  }

  CollectionReference<Map<String, dynamic>> participantsRefByCtxId(
      String ctxId,
      ) {
    return _contexts.doc(ctxId).collection('participants');
  }

  CollectionReference<Map<String, dynamic>> participantsRef({
    required String contextType,
    required String contextId,
  }) =>
      _contexts
          .doc(_contextKey(contextType: contextType, contextId: contextId))
          .collection('participants');

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('ChatService used before auth is ready');
    }
    return user.uid;
  }


  String get currentUserId => _currentUserId;


  String _contextKey({
    required String contextType,
    required String contextId,
  }) {
    return '${contextType}_$contextId';
  }



  // =======================================================
  // CONTEXTS
  // =======================================================

  Future<DocumentReference<Map<String, dynamic>>> getGlobalContext() async {
    final query =
    await _contexts.where('type', isEqualTo: 'GLOBAL').limit(1).get();

    if (query.docs.isNotEmpty) return query.docs.first.reference;

    return _contexts.add({
      'type': 'GLOBAL',
      'owner': {'type': 'SYSTEM', 'refId': null},
      'state': 'ACTIVE',
      'visibility': 'PUBLIC',
      'location': null,
      'metadata': {
        'title': 'MetaZone Global',
        'language': 'en',
      },
      'stats': {
        'participantsCount': 0,
        'messagesCount': 0,
        'lastActivityAt': FieldValue.serverTimestamp(),
      },
      'lifecycle': {
        'createdAt': FieldValue.serverTimestamp(),
        'activatedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> getPrivateContext(
      String otherUserId) async {
    final ids = [_currentUserId, otherUserId]..sort();
    final relationId = ids.join('_');

    final query = await _contexts
        .where('type', isEqualTo: 'PRIVATE')
        .where('owner.refId', isEqualTo: relationId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) return query.docs.first.reference;

    final doc = await _contexts.add({
      'type': 'PRIVATE',
      'owner': {'type': 'RELATION', 'refId': relationId},
      'state': 'ACTIVE',
      'visibility': 'PRIVATE',
      'stats': {
        'participantsCount': 2,
        'messagesCount': 0,
      },
      'lifecycle': {
        'createdAt': FieldValue.serverTimestamp(),
      },
    });

    for (final uid in ids) {
      await participantsRefByCtxId(doc.id).doc(uid).set({

        'userId': uid,
        'status': 'ACTIVE',
        'joinedAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
        'spamStrikes': 0,
      });
    }

    return doc;
  }

  Future<DocumentReference<Map<String, dynamic>>> getNearbyContext({
    required double lat,
    required double lng,
    required double radiusMeters,
    required String zoneId,
    String? title,
  }) async {
    final query = await _contexts
        .where('type', isEqualTo: 'NEARBY')
        .where('location.zoneId', isEqualTo: zoneId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) return query.docs.first.reference;

    return _contexts.add({
      'type': 'NEARBY',
      'owner': {'type': 'LOCATION', 'refId': zoneId},
      'state': 'ACTIVE',
      'visibility': 'PUBLIC',
      'location': {
        'lat': lat,
        'lng': lng,
        'radius': radiusMeters,
        'zoneId': zoneId,
      },
      'metadata': {
        'title': title ?? 'Nearby Chat',
      },
      'stats': {
        'participantsCount': 0,
        'messagesCount': 0,
      },
      'lifecycle': {
        'createdAt': FieldValue.serverTimestamp(),
      },
    });
  }

  // =======================================================
  // MESSAGES
  // =======================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream({
    required String contextType,
    required String contextId,
  }) {
    return messagesRef(
      contextType: contextType,
      contextId: contextId,
    )
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Query<Map<String, dynamic>> pagedMessagesQuery({
    required String contextId,
    DocumentSnapshot? lastDoc,
    int limit = 30,
  }) {
    var q = _messages(contextId)

        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      q = q.startAfterDocument(lastDoc);
    }

    return q;
  }

  Future<void> sendTextMessage({
    required String contextType,
    required String contextId,
    required String text,
    String? parentMessageId,
  }) async {
    if (_auth.currentUser == null) {
      throw StateError('User not authenticated');
    }
    if (text.trim().isEmpty) return;

    final ctxId = contextType == 'AR_OBJECT'
        ? contextId
        : _contextKey(
      contextType: contextType,
      contextId: contextId,
    );


    final ctxRef = _contexts.doc(ctxId);
    final ctxSnap = await ctxRef.get();

    if (!ctxSnap.exists) {
      await ctxRef.set({
        'type': contextType,
        'state': 'ACTIVE',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      if (ctxSnap.data()?['state'] != 'ACTIVE') return;
    }


    if (contextType == 'PRIVATE') {
      await _validatePrivateMessageSend(ctxId);
    } else {
      await _validateMessageSend(ctxId, text);
    }

    final participant =
    await _participants(ctxId).doc(_currentUserId).get();
    if (!participant.exists) {
      await _participants(ctxId).doc(_currentUserId).set({
        'userId': _currentUserId,
        'joinedAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'nearObject': true,
        'followed': true,
      });
    }


    final anon = participant.data()?['anonymous'];

    final senderData = (anon != null && anon['enabled'] == true)
        ? {
      'alias': anon['alias'],
      'isAnonymous': true,
    }
        : {
      'userId': _currentUserId,
      'isAnonymous': false,
    };

    final msgRef = await _messages(ctxId).add({
      'contextId': ctxId,
      'sender': senderData,
      'type': 'TEXT',
      'payload': {'text': text},
      'parentMessageId': parentMessageId,
      'createdAt': FieldValue.serverTimestamp(),
    });
// 🔔 AR Object followers
    if (contextType == 'AR_OBJECT') {
      await _notifyFollowers(
        contextId: contextId,
        messageId: msgRef.id,
        messageText: text,
      );
    }

// 🔔 Reply owner
    if (parentMessageId != null) {
      await _notifyReply(
        contextId: ctxId,
        parentMessageId: parentMessageId,
        senderId: _currentUserId,
        text: text,
      );
    }


    await _updateContextStats(ctxId);
  }


  Future<void> sendImageMessage({
    required String contextType,
    required String contextId,
    required File file,
  }) async {
    if (_auth.currentUser == null) {
      throw StateError('User not authenticated');
    }

    final ctxId = ctx(contextType, contextId);

    final ref = _storage
        .ref('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final participant =
    await _participants(ctxId).doc(_currentUserId).get();

    final anon = participant.data()?['anonymous'];

    final senderData = (anon != null && anon['enabled'] == true)
        ? {
      'alias': anon['alias'],
      'isAnonymous': true,
    }
        : {
      'userId': _currentUserId,
      'isAnonymous': false,
    };

    await _messages(ctxId).add({
      'contextId': ctxId,
      'sender': senderData,
      'type': 'IMAGE',
      'payload': {
        'mediaUrl': url,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _updateContextStats(ctxId);
    await _contexts.doc(ctxId).update({
      'metadata.lastMessage': '[IMAGE]',
      'metadata.lastMessageAt': FieldValue.serverTimestamp(),
    });

  }

  // =======================================================
  // PARTICIPANTS
  // =======================================================
  Future<void> markChatSeen({
    required String contextType,
    required String contextId,
  }) async {
    final ctxId = ctx(contextType, contextId);

    final snap = await _participants(ctxId)
        .doc(_currentUserId)
        .get();

    if (!snap.exists) return; // المستخدم لسه ما دخلش الشات

    await _participants(ctxId)
        .doc(_currentUserId)
        .set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

  }

  Future<void> setTyping({
    required String contextType,
    required String contextId,
    required bool isTyping,
  }) async {
    final ctxId = ctx(contextType, contextId);

    final snap = await _participants(ctxId)
        .doc(_currentUserId)
        .get();

    if (!snap.exists) return; // المستخدم لسه ما دخلش الشات

    await _participants(ctxId)
        .doc(_currentUserId)
        .set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

  }

  Stream<bool> typingStream({
    required String contextType,
    required String contextId,
  }) {
    final ctxId = ctx(contextType, contextId);

    return _participants(ctxId)
        .where('typing', isEqualTo: true)
        .snapshots()
        .map((s) {
      return s.docs.any((d) => d.id != _currentUserId);
    });
  }


  Future<void> joinContext(
      String contextType,
      String contextId,
      ) async {
    if (_auth.currentUser == null) {
      throw StateError('User not authenticated');
    }

    final ctxId = ctx(contextType, contextId);

    await _participants(ctxId).doc(_currentUserId).set({
      'userId': _currentUserId,
      'status': 'ACTIVE',
      'joinedAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'spamStrikes': 0,

      // 🔥 TEMP FIX — AR Object write access
      'followed': true,
      'nearObject': true,
    }, SetOptions(merge: true));


    await refreshOnlineStats(ctxId);
  }


  Future<void> markObjectChatSeen(String contextId) async {
    final ctxId = contextId;

    final snap = await _participants(ctxId)
        .doc(_currentUserId)
        .get();

    if (!snap.exists) return; // المستخدم لسه ما دخلش الشات

    await _participants(ctxId)
        .doc(_currentUserId)
        .set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

  }


  Duration _calculateDynamicCooldown(int activeUsers) {
    if (activeUsers <= 10) return Duration.zero;
    if (activeUsers <= 30) return const Duration(seconds: 3);
    if (activeUsers <= 80) return const Duration(seconds: 6);
    if (activeUsers <= 200) return const Duration(seconds: 10);
    return const Duration(seconds: 15);
  }


  // =======================================================
  // INTERNAL
  // =======================================================

  Future<void> _updateContextStats(String contextId) async {
    await _contexts.doc(contextId).set({
      'stats': {
        'messagesCount': FieldValue.increment(1),
        'lastActivityAt': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  Future<void> _validatePrivateMessageSend(String contextId) async {
    final uid = _currentUserId;

    // 1️⃣ لازم يكون مشارك في الشات
    final participantSnap =
    await _participants(contextId).doc(uid).get();

    if (!participantSnap.exists) {
      throw Exception('NOT_PARTICIPANT');
    }

    final data = participantSnap.data() ?? {};

    // 2️⃣ لو عامل Delete للشات
    if (data['deleted'] == true) {
      throw Exception('CHAT_DELETED_FOR_USER');
    }

    // 3️⃣ Block logic
    final ctxSnap = await _contexts.doc(contextId).get();
    final blockedBy = List<String>.from(
      ctxSnap.data()?['blockedBy'] ?? [],
    );

    if (blockedBy.contains(uid)) {
      throw Exception('USER_BLOCKED');
    }

    // 4️⃣ Private = no anonymous
    if (data['anonymous']?['enabled'] == true) {
      await disableAnonymousMode(contextId);
    }

    // 5️⃣ Update activity
    await _participants(contextId).doc(uid).set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }


  // =======================================================
  // ANTI-SPAM ENGINE
  // =======================================================

  Future<void> _validateMessageSend(String contextId, String text) async {
    final ctxId = contextId;
    final ref = _participants(ctxId)

        .doc(_currentUserId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw StateError('User not joined in this chat');
    }

    final data = snap.data() ?? {};
    await ref.set({
      'lastMessageText': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));


    if (!snap.exists) throw Exception();

    final rulesSnap = await _contexts.doc(contextId).get();
    final rules = rulesSnap.data()?['rules'] ?? {};

    final writePolicy = rules['writePolicy'];

    final isNear = data['nearObject'] == true;
    final isFollower = data['followed'] == true;

    if (writePolicy == 'NEAR_OR_FOLLOW') {
      if (!isNear && !isFollower) {
        throw Exception(); // read-only
      }
    }

    final now = DateTime.now();

    if ((data['status'] ?? 'ACTIVE') == 'MUTED') throw Exception();

    final cooldownUntil = data['cooldownUntil'] as Timestamp?;
    if (cooldownUntil != null && now.isBefore(cooldownUntil.toDate())) {
      throw Exception();
    }
    final anon = data['anonymous'];
    if (anon != null && anon['enabled'] == true) {
      final exp = anon['expiresAt'] as Timestamp?;
      if (exp != null && DateTime.now().isAfter(exp.toDate())) {
        await disableAnonymousMode(contextId);
      }
    }

    final last = data['lastMessageAt'] as Timestamp?;
    if (last != null &&
        now.difference(last.toDate()).inSeconds < 2) {
      await _registerSpamStrike(ref, data);
      final modSnap =
      await _db.collection('user_moderation').doc(_currentUserId).get();

      if (modSnap.exists) {
        final mod = modSnap.data()!;
        if (mod['status'] == 'TEMP_BANNED') {
          final until = mod['until'] as Timestamp?;
          if (until != null && DateTime.now().isBefore(until.toDate())) {
            throw Exception();
          }
        }
      }

      throw Exception();
    }

    // 🔵 Update activity

    await ref.set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

// 🟣 Dynamic Slow Mode
    final crowd = await _getActiveCrowdCount(contextId);
    final dynamicCooldown = _calculateDynamicCooldown(crowd);

    if (dynamicCooldown > Duration.zero) {
      await ref.set({
        'cooldownUntil':
        Timestamp.fromDate(DateTime.now().add(dynamicCooldown)),
      }, SetOptions(merge: true));
    }


    await ref.set({
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _registerSpamStrike(
      DocumentReference ref,
      Map<String, dynamic> data,
      ) async {
    final strikes = ((data['spamStrikes'] ?? 0) as int) + 1;

    if (strikes >= 3) {
      await ref.update({
        'status': 'MUTED',
        'spamStrikes': 0,
        'cooldownUntil':
        Timestamp.fromDate(DateTime.now().add(const Duration(seconds: 60))),
      });
    } else {
      await ref.update({
        'spamStrikes': strikes,
        'cooldownUntil':
        Timestamp.fromDate(DateTime.now().add(const Duration(seconds: 5))),
      });
    }
  }
  Future<int> _getActiveCrowdCount(String contextId) async {
    final since =
    Timestamp.fromDate(DateTime.now().subtract(const Duration(seconds: 30)));
    final ctxId = contextId;

    final snap = await _participants(ctxId)



        .where('lastActiveAt', isGreaterThan: since)
        .get();

    return snap.size;
  }
  Future<void> sendHeartbeat(String contextId) async {
    final ctxId = contextId;

    final snap = await _participants(ctxId)
        .doc(_currentUserId)
        .get();

    if (!snap.exists) return; // المستخدم لسه ما دخلش الشات

    await _participants(ctxId)
        .doc(_currentUserId)
        .set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
   SetOptions(merge: true);
  }

  Future<int> getOnlineCount(String contextId) async {
    final since = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(seconds: 20)),

    );
    final ctxId = contextId;

    final snap = await _participants(ctxId)



        .where('lastActiveAt', isGreaterThan: since)
        .get();

    return snap.size;
  }

  Future<void> refreshOnlineStats(String contextId) async {
    final count = await getOnlineCount(contextId);

    final ctxId = contextId;
    await _contexts.doc(ctxId).update({
      'stats.participantsCount': count,
    });
  }
  String _generateAlias() {
    const prefixes = [
      'Shadow',
      'Neo',
      'AR',
      'Ghost',
      'Meta',
      'Silent',
    ];

    const suffixes = [
      'Fox',
      'Walker',
      'Specter',
      'Rider',
      'Visitor',
      'Nomad',
    ];

    final p = prefixes[DateTime.now().millisecondsSinceEpoch % prefixes.length];
    final s = suffixes[DateTime.now().millisecondsSinceEpoch % suffixes.length];
    final n = DateTime.now().millisecondsSinceEpoch % 100;

    return '$p$s$n';
  }
  Future<void> enableAnonymousMode(String contextId,
      {Duration? duration}) async {
    final ctxSnap = await _contexts.doc(contextId).get();
    if (ctxSnap.data()?['type'] == 'PRIVATE') return;

    final ctxId = contextId;

    final alias = _generateAlias();
    final expires = DateTime.now().add(
      duration ?? const Duration(hours: 1),
    );

    await _participants(ctxId)


        .doc(_currentUserId).set({
      'anonymous': {
        'enabled': true,
        'alias': alias,
        'sessionId': _db.collection('_').doc().id,
        'expiresAt': Timestamp.fromDate(expires),
      }
    }, SetOptions(merge: true));
  }
  Future<void> disableAnonymousMode(String contextId) async {
    final ctxId = contextId;

    await _participants(ctxId)


        .doc(_currentUserId).set({
      'anonymous': {
        'enabled': false,
      }
    }, SetOptions(merge: true));
  }
// =======================================================
// REPORTING & MODERATION
// =======================================================

  Future<void> reportMessage({
    required String contextId,
    required String messageId,
    required String reason,
  }) async {
    final reporterId = _currentUserId;

    final reportRef = _db.collection('chat_reports').doc();

    await reportRef.set({
      'contextId': contextId,
      'messageId': messageId,
      'reportedBy': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'OPEN',
    });

    // 👇 نزوّد عداد البلاغات على الرسالة
    final msgRef = _messages(contextId).doc(messageId);

    await msgRef.set({
      'moderation': {
        'reportsCount': FieldValue.increment(1),
        'isFlagged': true,
      }
    }, SetOptions(merge: true));

    // 👇 نشغّل Auto Moderation
    await _autoModerateMessage(contextId, messageId);
  }
  Future<void> softDeleteMessage({
    required String contextId,
    required String messageId,
  }) async {
    await _messages(contextId).doc(messageId).set({
      'moderation': {
        'hidden': true,
        'action': 'SOFT_DELETE',
        'by': _currentUserId,
        'at': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  Future<void> _autoModerateMessage(
      String contextId,
      String messageId,
      ) async {
    final msgRef = _messages(contextId).doc(messageId);
    final snap = await msgRef.get();

    if (!snap.exists) return;

    final data = snap.data() ?? {};
    final moderation = data['moderation'] ?? {};
    final reports = moderation['reportsCount'] ?? 0;

    // 🔴 لو الرسالة اتبلغ عنها 3 مرات
    if (reports >= 3) {
      await msgRef.set({
        'moderation': {
          'hidden': true,
          'autoAction': 'HIDDEN_BY_REPORTS',
        }
      }, SetOptions(merge: true));

      final sender = data['sender'];
      final userId = sender?['userId'];

      if (userId != null) {
        await _registerUserModerationStrike(userId);
      }
    }
  }
  Future<void> _registerUserModerationStrike(String userId) async {
    final ref = _db.collection('user_moderation').doc(userId);
    final snap = await ref.get();

    final strikes = (snap.data()?['strikes'] ?? 0) + 1;

    if (strikes >= 5) {
      // 🚫 حظر مؤقت شامل
      await ref.set({
        'strikes': strikes,
        'status': 'TEMP_BANNED',
        'until': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 12)),
        ),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await ref.set({
        'strikes': strikes,
        'status': 'WARNING',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
// ================================
// AR OBJECT CHAT
// ================================
  Future<void> closeARObjectChat(String contextId) async {
    final ctxId = contextId;
    await _contexts.doc(ctxId).update({
      'state': 'CLOSED',
      'closedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> ensureARObjectContext({
    required String objectId,
    required String title,
  }) async {

    final ctxId = 'AR_OBJECT_$objectId';
    final ref = _contexts.doc(ctxId);

    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'type': 'AR_OBJECT',
        'owner': {
          'type': 'AR_OBJECT',
          'refId': objectId,
        },
        'state': 'ACTIVE',
        'visibility': 'PUBLIC',
        'metadata': {
          'title': title,
          'mode': 'PERSISTENT',
        },
        'rules': {
          'writePolicy': 'NEAR_OR_FOLLOW',
          'readPolicy': 'ALWAYS',
          'anonymousAllowed': true,
        },
        'stats': {
          'messagesCount': 0,
          'participantsCount': 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return ctxId;
  }

  Stream<Map<String, dynamic>?> arObjectContextStream(String objectId) {
    final ctxId = 'AR_OBJECT_$objectId';
    return _contexts.doc(ctxId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  // ================================
// AR OBJECT PROXIMITY
// ================================

  Future<void> updateNearObject(
      String contextId, {
        required bool isNear,
      }) async {
    final ctxId = contextId;

    await _participants(ctxId)


        .doc(_currentUserId).set({
      'nearObject': isNear,
    }, SetOptions(merge: true));
  }
// ================================
// THREAD REPLIES
// ================================

  Future<void> replyToMessage({
    required String contextId,
    required String parentMessageId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    final ctxId = contextId;
    await _validateMessageSend(ctxId, text);

    final parentSnap =
    await _messages(contextId).doc(parentMessageId).get();

    if (!parentSnap.exists) return;

    final parentData = parentSnap.data()!;
    final rootId =
        parentData['thread']?['rootId'] ?? parentMessageId;

    final participant =
    await _participants(ctxId).doc(_currentUserId).get();


    final anon = participant.data()?['anonymous'];

    final senderData = (anon != null && anon['enabled'] == true)
        ? {
      'alias': anon['alias'],
      'isAnonymous': true,
    }
        : {
      'userId': _currentUserId,
      'isAnonymous': false,
    };

    // 1️⃣ إضافة الرد
    await _messages(contextId).add({
      'contextId': contextId,
      'sender': senderData,
      'type': 'TEXT',
      'payload': {
        'text': text,
      },
      'thread': {
        'parentId': parentMessageId,
        'rootId': rootId,
        'repliesCount': 0,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ زيادة عداد الردود
    await _messages(contextId).doc(parentMessageId).update({
      'thread.repliesCount': FieldValue.increment(1),
    });
  }
// =======================================================
// AR OBJECT FOLLOW SYSTEM
// =======================================================

  Future<void> followARObject(String objectId) async {
    final uid = _currentUserId;
    final now = FieldValue.serverTimestamp();

    final batch = _db.batch();

    // object → followers
    final objectFollowerRef = _db
        .collection('ar_object_follows')
        .doc(objectId)
        .collection('followers')
        .doc(uid);

    batch.set(objectFollowerRef, {
      'followedAt': now,
      'notifications': true,
    });

    // user → followed objects
    final userFollowRef = _db
        .collection('users')
        .doc(uid)
        .collection('followed_objects')
        .doc(objectId);

    batch.set(userFollowRef, {
      'followedAt': now,
    });

    await batch.commit();
  }

  Future<void> unfollowARObject(String objectId) async {
    final uid = _currentUserId;

    final batch = _db.batch();

    batch.delete(
      _db
          .collection('ar_object_follows')
          .doc(objectId)
          .collection('followers')
          .doc(uid),
    );

    batch.delete(
      _db
          .collection('users')
          .doc(uid)
          .collection('followed_objects')
          .doc(objectId),
    );

    await batch.commit();
  }

  Future<bool> isFollowingARObject(String objectId) async {
    final uid = _currentUserId;

    final doc = await _db
        .collection('ar_object_follows')
        .doc(objectId)
        .collection('followers')
        .doc(uid)
        .get();

    return doc.exists;
  }

  Stream<int> followersCountStream(String objectId) {
    return _db
        .collection('ar_object_follows')
        .doc(objectId)
        .collection('followers')
        .snapshots()
        .map((s) => s.size);
  }
// =======================================================
// NOTIFICATIONS — AR OBJECT CHAT
// =======================================================

  Future<void> _notifyFollowers({

    required String contextId,        // objectId
    required String messageId,
    required String messageText,
  }) async {
    final ctxId = contextId;

    final p =await _participants(ctxId).doc(_currentUserId).get();

    if (p.data()?['muted'] == true) return;

    final followersSnap = await _db
        .collection('ar_object_follows')
        .doc(contextId)
        .collection('followers')
        .get();
// 🧠 Smart Dedup — prevent duplicate notifications
    final dedupId = '${contextId}_${messageId}_AR_OBJECT';

    final dedupSnap = await _db
        .collection('notification_dedup')
        .doc(dedupId)
        .get();

    if (dedupSnap.exists) return;

    final batch = _db.batch();
    final now = FieldValue.serverTimestamp();

    for (final doc in followersSnap.docs) {
      final userId = doc.id;

      // مايبعتش Notification لنفسه
      if (userId == _currentUserId) continue;

      final notifRef = _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc();

      batch.set(notifRef, {
        'type': 'AR_OBJECT_NEW_COMMENT',
        'contextId': contextId,
        'messageId': messageId,
        'text': messageText,
        'fromUserId': _currentUserId,
        'createdAt': now,
        'read': false,
      });
    }
// 🧠 تسجيل الإشعار كـ sent (Dedup Lock)
    await _db
        .collection('notification_dedup')
        .doc(dedupId)
        .set({
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

// ================================
// GET FOLLOWERS IDS
// ================================
  Future<List<String>> getARObjectFollowers(String objectId) async {
    final snap = await _db
        .collection('ar_objects')
        .doc(objectId)
        .collection('followers')
        .get();

    return snap.docs.map((d) => d.id).toList();
  }
// ================================
// CREATE NOTIFICATION
// ================================
  Future<void> _createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String objectId,
    required String contextId,
    String? messageId,
    Map<String, dynamic>? meta,
  }) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc();

    await ref.set({
      'type': type,
      'title': title,
      'body': body,
      'objectId': objectId,
      'contextId': contextId,
      'messageId': messageId,
      'meta': meta ?? {},
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
// ================================
// NOTIFY AR OBJECT FOLLOWERS
// ================================
  Future<void> notifyARObjectFollowers({
    required String objectId,
    required String contextId,
    required String objectName,
    required String senderId,
    required String senderName,
    required String messageText,
    String? messageId,
  }) async {
    final followers = await getARObjectFollowers(objectId);

    for (final uid in followers) {
      // ما نبعتش لنفس الشخص
      if (uid == senderId) continue;

      await _createNotification(
        userId: uid,
        type: 'ar_object_comment',
        title: 'New comment on $objectName',
        body: '$senderName: $messageText',
        objectId: objectId,
        contextId: contextId,
        messageId: messageId,
        meta: {
          'senderId': senderId,
          'senderName': senderName,
        },
      );
    }
  }
// ================================
// NOTIFY OBJECT OWNER
// ================================
  Future<void> notifyARObjectOwner({
    required String objectId,
    required String contextId,
    required String objectName,
    required String senderId,
    required String senderName,
    required String messageText,
  }) async {
    final snap =
    await _db.collection('ar_objects').doc(objectId).get();

    if (!snap.exists) return;

    final ownerId = snap.data()!['ownerId'];
    if (ownerId == senderId) return;

    await _createNotification(
      userId: ownerId,
      type: 'ar_object_owner',
      title: 'Activity on your AR Object',
      body: '$senderName commented on $objectName',
      objectId: objectId,
      contextId: contextId,
      meta: {
        'senderId': senderId,
        'senderName': senderName,
      },
    );
  }
  Future<void> _notifyReply({
    required String contextId,
    required String parentMessageId,
    required String senderId,
    required String text,
  }) async {
    final parentSnap = await _messages(contextId)

        .doc(parentMessageId)
        .get();
    final ctxId = contextId;

    final p =  await _participants(ctxId).doc(_currentUserId).get();

    if (p.data()?['muted'] == true) return;

    if (!parentSnap.exists) return;

    final parent = parentSnap.data()!;
    final parentSender = parent['sender'];

    if (parentSender['isAnonymous'] == true) return;
    if (parentSender['userId'] == senderId) return;

    await _db
        .collection('users')
        .doc(parentSender['userId'])
        .collection('notifications')
        .add({
      'type': 'AR_REPLY',
      'contextId': contextId,
      'parentMessageId': parentMessageId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });

  }

// =======================================================
// MUTE AR OBJECT (Notifications Control)
// =======================================================
  Future<void> _notifyMention({
    required String contextId,
    required String username,
    required String senderId,
    required String text,
  }) async {

    final snap = await _db
        .collection('usernames')
        .doc(username)
        .get();
    final ctxId = contextId;

    if (!snap.exists) return;
    final p = await _participants(ctxId).doc(_currentUserId).get();

    if (p.data()?['muted'] == true) return;

    final userId = snap['userId'];
    if (userId == senderId) return;

    await _createNotification(
      userId: userId,
      type: 'mention',
      title: 'You were mentioned',
      body: text,
      objectId: contextId,
      contextId: contextId,
    );
  }

  Future<void> muteObject(String contextId) async {
    final ctxId = contextId;

    await _participants(ctxId)



        .doc(_currentUserId)
        .set({
      'muted': true,
    }, SetOptions(merge: true));
  }

  Future<void> unmuteObject(String contextId) async {
    final ctxId = contextId;

    await _participants(ctxId)



        .doc(_currentUserId)
        .set({
      'muted': false,
    }, SetOptions(merge: true));
  }
  Stream<List<Map<String, dynamic>>> privateConversationsStream() {
    final uid = _currentUserId;

    return _contexts
        .where('type', isEqualTo: 'PRIVATE')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> result = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ctxId = doc.id;

        // هل المستخدم مشارك؟
        final participantSnap =
        await _participants(ctxId).doc(uid).get();

        if (!participantSnap.exists) continue;

        final participant = participantSnap.data() ?? {};

        // هل المستخدم عامل Delete للشات؟
        if (participant['deleted'] == true) continue;

        // هات آخر رسالة
        final lastMsgSnap = await _messages(ctxId)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        String lastText = '';
        Timestamp? lastTime;

        if (lastMsgSnap.docs.isNotEmpty) {
          final msg = lastMsgSnap.docs.first.data();
          lastTime = msg['createdAt'];

          if (msg['type'] == 'TEXT') {
            lastText = msg['payload']?['text'] ?? '';
          } else {
            lastText = '[${msg['type']}]';
          }
        }


        // هات الطرف التاني
        final users = List<String>.from(data['owner']?['refId']?.split('_') ?? []);
        final otherUserId = users.firstWhere((u) => u != uid, orElse: () => '');

        result.add({
          'contextId': ctxId,
          'userId': otherUserId,
          'name': 'User', // هنعوضها لاحقًا من users collection
          'last': lastText,
          'time': lastTime,
          'unread': 0, // المرحلة الجاية
          'online': false,
          'avatar': null,
        });
      }

      // ترتيب حسب آخر رسالة
      result.sort((a, b) {
        final ta = a['time'] as Timestamp?;
        final tb = b['time'] as Timestamp?;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });

      return result;
    });
  }
  Future<int> getPrivateUnreadCount(String contextId) async {
    final uid = _currentUserId;

    final participantSnap =
    await _participants(contextId).doc(uid).get();

    if (!participantSnap.exists) return 0;

    final lastSeen =
    participantSnap.data()?['lastSeenMessageAt'] as Timestamp?;

    Query<Map<String, dynamic>> q =
    _messages(contextId);

    if (lastSeen != null) {
      q = q.where('createdAt', isGreaterThan: lastSeen);
    }

    final snap = await q.get();

    // فلترة يدوية بدل Firestore
    return snap.docs
        .where((d) => d.data()['sender']?['userId'] != uid)
        .length;
  }

  Future<void> deletePrivateChatForMe(String contextId) async {
    await _participants(contextId)
        .doc(_currentUserId)
        .set({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  Future<void> blockUserInPrivateChat(String contextId) async {
    final ctxSnap = await _contexts.doc(contextId).get();
    if (!ctxSnap.exists) return;

    await _contexts.doc(contextId).set({
      'blockedBy': FieldValue.arrayUnion([_currentUserId]),
    }, SetOptions(merge: true));

  }

  Future<void> unblockUserInPrivateChat(String contextId) async {
    final ctxSnap = await _contexts.doc(contextId).get();
    if (!ctxSnap.exists) return;

    await _contexts.doc(contextId).set({
      'blockedBy': FieldValue.arrayUnion([_currentUserId]),
    }, SetOptions(merge: true));

  }
}
