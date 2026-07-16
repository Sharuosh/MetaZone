import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// LOGIN
  Future<String> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await result.user?.reload();

      if (!(result.user?.emailVerified ?? false)) {
        return "EMAIL_NOT_VERIFIED";
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
        case "user-disabled":
          return "USER_DISABLED";
        default:
          return "ERROR";
      }
    }
  }

  /// REGISTER
  Future<String> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await result.user?.sendEmailVerification();

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

  /// RESEND VERIFY
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// REFRESH VERIFY
  Future<bool> refreshEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return user.emailVerified;
  }

  /// RESET PASSWORD
  Future<String> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "USER_NOT_FOUND";
      }
      return "ERROR";
    }
  }

  /// LOGOUT
  Future<void> signOut() async => await _auth.signOut();

  bool isEmailVerified() => _auth.currentUser?.emailVerified ?? false;
}
