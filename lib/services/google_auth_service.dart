import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static final CollectionReference<Map<String, dynamic>>
  _users =
  FirebaseFirestore.instance.collection('users');

  static final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  static bool _initialized = false;

  static Future<void> _initialize() async {
    if (_initialized) {
      return;
    }

    await _googleSignIn.initialize();

    _initialized = true;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await _initialize();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw StateError(
          'Google Sign-In authentication is not '
              'supported on this platform.',
        );
      }

      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken =
          googleAuth.idToken;

      if (idToken == null ||
          idToken.trim().isEmpty) {
        throw StateError(
          'Google Sign-In returned no ID token.',
        );
      }

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(
        credential,
      );

      final User? user =
          userCredential.user;

      if (user == null) {
        return null;
      }

      final DocumentReference<
          Map<String, dynamic>>
      userReference =
      _users.doc(user.uid);

      final DocumentSnapshot<
          Map<String, dynamic>>
      document =
      await userReference.get();

      if (!document.exists) {
        await userReference.set(
          {
            'uid': user.uid,
            'email': user.email,
            'name':
            user.displayName ?? 'Meta User',
            'avatar': user.photoURL,
            'provider': 'google',
            'createdAt':
            FieldValue.serverTimestamp(),
            'lastLogin':
            FieldValue.serverTimestamp(),
          },
        );
      } else {
        await userReference.update(
          {
            'lastLogin':
            FieldValue.serverTimestamp(),
          },
        );
      }

      return userCredential;
    } on GoogleSignInException catch (error) {
      throw StateError(
        'Google Sign-In failed: '
            '${error.code} ${error.description ?? ''}',
      );
    } catch (error) {
      throw StateError(
        'Google Sign-In failed: $error',
      );
    }
  }

  static Future<void> signOutGoogle() async {
    await _initialize();
    await _googleSignIn.signOut();
  }
}