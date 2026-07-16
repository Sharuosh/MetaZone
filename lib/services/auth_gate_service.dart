import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGateService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User> signInAnonymously() async {
    User? user = _auth.currentUser;

    if (user == null) {
      final cred = await _auth.signInAnonymously();
      user = cred.user!;
    }

    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        "uid": user.uid,
        "type": "anonymous",
        "displayName": "Guest",
        "username": "guest_${user.uid.substring(0, 6)}",
        "bio": "",
        "xp": 0,
        "arSpotsCount": 0,
        "creationsCount": 0,
        "followers": 0,
        "following": 0,
        "disabled": false,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    return user;
  }
}
