import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// =========================
  /// LOGIN
  /// =========================
  Future<String> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user!;
      await user.reload();

      final doc = await _db.collection("users").doc(user.uid).get();

      if (!doc.exists) {
        return "NO_PROFILE";
      }

      // check disabled
      if ((doc.data()?["disabled"] ?? false) == true) {
        await _auth.signOut();
        return "USER_DISABLED";
      }

      // check OTP verification instead of emailVerified
      if ((doc.data()?["emailVerified"] ?? false) == false) {
        return "OTP_REQUIRED";
      }

      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "USER_NOT_FOUND";
        case "wrong-password":
          return "WRONG_PASSWORD";
        case "invalid-email":
          return "INVALID_EMAIL";
        default:
          return "ERROR";
      }
    }
  }

  /// =========================
  /// REGISTER (create account + OTP doc)
  /// =========================
  Future<String> signUpWithEmail(String email, String password, String username) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user!;

      // Save base user record
      await _db.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": email.trim(),
        "username": username.trim(),
        "emailVerified": false,
        "disabled": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "EMAIL_EXISTS";
        case "weak-password":
          return "WEAK_PASSWORD";
        case "invalid-email":
          return "INVALID_EMAIL";
        default:
          return "ERROR";
      }
    }
  }

  /// =========================
  /// GENERATE OTP
  /// =========================
  Future<String> createOtp() async {
    final user = _auth.currentUser;
    if (user == null) return "NOT_LOGGED";

    final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    await _db.collection("emailOtps").doc(user.uid).set({
      "code": code,
      "verified": false,
      "attempts": 0,
      "createdAt": FieldValue.serverTimestamp(),
      "expiresAt": DateTime.now().add(const Duration(minutes: 5)),
    });

    return code; // يعرضه في التطبيق مؤقتًا بدل البريد
  }

  /// =========================
  /// VERIFY OTP
  /// =========================
  Future<String> verifyOtp(String code) async {
    final user = _auth.currentUser;
    if (user == null) return "NOT_LOGGED";

    final snap = await _db.collection("emailOtps").doc(user.uid).get();
    if (!snap.exists) return "NO_CODE";

    final data = snap.data()!;
    final saved = data["code"].toString();
    final attempts = data["attempts"] ?? 0;
    final expiresAt = (data["expiresAt"] as Timestamp).toDate();

    if (attempts >= 5) return "TOO_MANY_ATTEMPTS";
    if (DateTime.now().isAfter(expiresAt)) return "EXPIRED";

    await snap.reference.update({"attempts": attempts + 1});

    if (code != saved) return "WRONG_CODE";

    // success
    await snap.reference.update({"verified": true});

    await _db.collection("users").doc(user.uid).update({
      "emailVerified": true,
    });

    return "SUCCESS";
  }

  /// LOGOUT
  Future<void> signOut() async => await _auth.signOut();

  /// UI helper
  bool isOtpVerified() => _auth.currentUser != null;
}
