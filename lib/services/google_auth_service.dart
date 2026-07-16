import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final _auth = FirebaseAuth.instance;
  static final _users = FirebaseFirestore.instance.collection("users");

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user!;

      final doc = await _users.doc(user.uid).get();

      if (!doc.exists) {
        await _users.doc(user.uid).set({
          "uid": user.uid,
          "email": user.email,
          "name": user.displayName ?? "Meta User",
          "avatar": user.photoURL,
          "provider": "google",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return userCred;
    } catch (e) {
      print("GOOGLE LOGIN ERROR: $e");
      rethrow;
    }
  }
}
