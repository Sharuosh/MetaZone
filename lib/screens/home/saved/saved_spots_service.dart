import 'package:cloud_firestore/cloud_firestore.dart';
import 'saved_spot_model.dart';

class SavedSpotsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<SavedSpot>> streamSaved(String uid) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("saved_spots")
        .orderBy("savedAt", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => SavedSpot.fromFirestore(d.data(), d.id)).toList());
  }

  Future<void> toggleSave(String uid, SavedSpot s) async {
    final ref = _db.collection("users").doc(uid).collection("saved_spots").doc(s.id);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set(s.toJson(), SetOptions(merge: true));
    }
  }

  Future<bool> isSaved(String uid, String spotId) async {
    final doc = await _db
        .collection("users")
        .doc(uid)
        .collection("saved_spots")
        .doc(spotId)
        .get();
    return doc.exists;
  }
}
