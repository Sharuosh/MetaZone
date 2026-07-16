import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserBootstrapService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔑 Ensure user document exists
  Future<void> ensureUserInitialized() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user");
    }

    final userRef = _db.collection("users").doc(user.uid);
    final snap = await userRef.get();

    if (snap.exists) return; // ✅ already initialized

    final username = _generateTempUsername(user.uid);

    await userRef.set({
      "uid": user.uid,
      "username": username,
      "email": null,
      "isAnonymous": user.isAnonymous,
      "disabled": false,
      "createdAt": FieldValue.serverTimestamp(),
      "avatar":
      "https://ui-avatars.com/api/?name=$username&background=0D8ABC&color=fff",
    });
  }

  /// 🧩 generate stable temp username
  String _generateTempUsername(String uid) {
    return "guest_${uid.substring(0, 6)}";
  }
}
