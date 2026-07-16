import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ARObjectChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;
  bool get isAnonymous => _auth.currentUser!.isAnonymous;

  // ============================
  // CREATE / ENSURE AR OBJECT
  // ============================
  Future<void> ensureARObject({
    required String objectId,
    required String name,
    required double lat,
    required double lng,
  }) async {
    final ref = _db.collection('ar_objects').doc(objectId);

    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      "id": objectId,
      "name": name,
      "lat": lat,
      "lng": lng,
      "heat": 0,
      "commentsCount": 0,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // ============================
  // ADD COMMENT (CORE)
  // ============================
  Future<void> addComment({
    required String objectId,
    required String text,
  }) async {
    final ref = _db
        .collection('ar_objects')
        .doc(objectId)
        .collection('comments')
        .doc();

    await ref.set({
      "text": text.trim(),
      "authorId": uid,
      "authorType": isAnonymous ? "anonymous" : "user",
      "reactions": {},
      "heat": 1,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _db.collection('ar_objects').doc(objectId).set({
      "heat": FieldValue.increment(1),
      "commentsCount": FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // ============================
  // STREAM COMMENTS
  // ============================
  Stream<QuerySnapshot<Map<String, dynamic>>> streamComments(
      String objectId,
      ) {
    return _db
        .collection('ar_objects')
        .doc(objectId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============================
  // REACTIONS / HEAT
  // ============================
  Future<void> react({
    required String objectId,
    required String commentId,
    required String type, // like | fire
  }) async {
    final ref = _db
        .collection('ar_objects')
        .doc(objectId)
        .collection('comments')
        .doc(commentId);

    final inc = type == "fire" ? 2 : 1;

    await ref.set({
      "reactions.$type": FieldValue.increment(1),
      "heat": FieldValue.increment(inc),
    }, SetOptions(merge: true));

    await _db.collection('ar_objects').doc(objectId).update({
      "heat": FieldValue.increment(inc),
    });
  }
}
