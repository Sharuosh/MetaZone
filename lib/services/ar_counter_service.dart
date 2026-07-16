import 'package:cloud_firestore/cloud_firestore.dart';

class ARCounterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ===============================
  /// Recalculate ALL AR Counters
  /// ===============================
  Future<void> recalculateAll(String uid) async {
    final portals = await _firestore
        .collection("ar_spots")
        .where("ownerId", isEqualTo: uid)
        .get();

    final creations = await _firestore
        .collection("creations")
        .where("creatorId", isEqualTo: uid)
        .get();

    final media = await _firestore
        .collection("user_media")
        .where("uid", isEqualTo: uid)
        .get();

    await _firestore.collection("users").doc(uid).update({
      "arSpotsCount": portals.docs.length,
      "creationsCount": creations.docs.length,
      "mediaCount": media.docs.length,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ===============================
  /// Increment Single Counter (Safe)
  /// ===============================
  Future<void> increment(String uid, String field, {int by = 1}) async {
    await _firestore.collection("users").doc(uid).update({
      field: FieldValue.increment(by),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ===============================
  /// Decrement Single Counter (Safe)
  /// ===============================
  Future<void> decrement(String uid, String field, {int by = 1}) async {
    await _firestore.collection("users").doc(uid).update({
      field: FieldValue.increment(-by),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
