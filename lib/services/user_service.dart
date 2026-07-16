import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String usersCol = 'users';

  // -------------------------------
  // IDs & generators
  // -------------------------------

  String _generateMetaId(String uid) {
    return "META-${uid.substring(0, 6).toUpperCase()}";
  }

  String _generateUsername(String email) {
    final base =
    email.split("@")[0].replaceAll(RegExp(r'[^a-zA-Z0-9_.]'), "");
    return base.isEmpty ? "metazone_user" : base.toLowerCase();
  }

  // -------------------------------
  // Create user doc if missing
  // -------------------------------

  Future<void> createIfNotExist(User user) async {

    final ref = _firestore.collection(usersCol).doc(user.uid);
    final snap = await ref.get();

    if (snap.exists) return;

    final username = _generateUsername(user.email ?? "user");

    // reserve username
    await _firestore.collection("usernames").doc(username).set({
      "uid": user.uid,
    });

    await ref.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'metaId': _generateMetaId(user.uid),
      'username': username,
      'displayName': user.displayName ?? 'مستكشف جديد 🌌',
      'photoUrl': user.photoURL ?? '',
      'coverUrl': '',
      'bio': 'أهلاً بك في Meta Zone – عالمك الموازي!',
      'verified': false,
      'profileCompletion': 0,

      // gamification
      'xp': 0,
      'level': 1,
      'achievements': [],
      'rank': 'rookie',

      // social
      'followers': 0,
      'following': 0,
      'followingList': [],

      // AR counters
      'arSpotsCount': 0,
      'creationsCount': 0,
      'mediaCount': 0,

      // links
      'social': {
        'instagram': '',
        'twitter': '',
        'tiktok': '',
        'youtube': '',
      },

      'isPrivateProfile': false,
      'profileUrl': 'https://metaz.one/u/${username}',

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // -------------------------------
  // Read
  // -------------------------------

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection(usersCol).doc(uid).get();
    return doc.data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _firestore.collection(usersCol).doc(uid).snapshots();
  }

  // -------------------------------
  // Update (generic merge)
  // -------------------------------

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(usersCol)
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  // -------------------------------
  // Avatar & Cover
  // -------------------------------

  Future<String?> uploadAvatar(String uid, File file, {String? oldUrl}) async {
    try {
      if (oldUrl != null && oldUrl.isNotEmpty) {
        await deleteFileByUrl(oldUrl);
      }

      final ref = _storage
          .ref()
          .child('users/avatars/$uid-${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await updateProfile(uid, {"photoUrl": url});
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadCover(String uid, File file, {String? oldUrl}) async {
    try {
      if (oldUrl != null && oldUrl.isNotEmpty) {
        await deleteFileByUrl(oldUrl);
      }

      final ref = _storage
          .ref()
          .child('users/covers/$uid-${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await updateProfile(uid, {"coverUrl": url});
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }

  // -------------------------------
  // Username system (SINGLE SOURCE OF TRUTH)
  // -------------------------------

  bool validateUsernameFormat(String username) {
    final regex = RegExp(r'^[a-z0-9._]{3,20}$');
    return regex.hasMatch(username);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final clean = username.trim().toLowerCase();
    final doc = await _firestore.collection("usernames").doc(clean).get();
    return !doc.exists;
  }

  Future<bool> updateUsername(
      String uid, String newUsername, String oldUsername) async {
    newUsername = newUsername.trim().toLowerCase();

    if (!validateUsernameFormat(newUsername)) return false;

    final newDoc = _firestore.collection("usernames").doc(newUsername);
    final oldDoc =
    _firestore.collection("usernames").doc(oldUsername.toLowerCase());

    return await _firestore.runTransaction((t) async {
      final exists = await t.get(newDoc);

      if (exists.exists) return false;

      t.set(newDoc, {"uid": uid});
      t.delete(oldDoc);

      t.update(_firestore.collection(usersCol).doc(uid), {
        "username": newUsername,
        "profileUrl": "https://metaz.one/u/$newUsername",
        "updatedAt": FieldValue.serverTimestamp(),
      });


      return true;
    });
  }

  // -------------------------------
  // AR counters
  // -------------------------------

  Future<void> refreshArCounters(String uid) async {
    final arSpots = await _firestore
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

    await updateProfile(uid, {
      "arSpotsCount": arSpots.docs.length,
      "creationsCount": creations.docs.length,
      "mediaCount": media.docs.length,
    });
  }

  // -------------------------------
  // Gamification
  // -------------------------------

  Future<void> addXp(String uid, int xpToAdd) async {
    final ref = _firestore.collection(usersCol).doc(uid);

    await _firestore.runTransaction((t) async {
      final snap = await t.get(ref);

      int xp = (snap['xp'] ?? 0) + xpToAdd;
      int level = (snap['level'] ?? 1);

      while (xp >= 1000) {
        xp -= 1000;
        level += 1;
      }

      t.update(ref, {
        'xp': xp,
        'level': level,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await checkAndGrantAchievements(uid);

  }

  // -------------------------------
  // Follow system
  // -------------------------------

  Future<void> follow(String currentUid, String targetUid) async {
    if (currentUid == targetUid) return;

    final currentRef = _firestore.collection(usersCol).doc(currentUid);
    final targetRef = _firestore.collection(usersCol).doc(targetUid);

    await _firestore.runTransaction((t) async {
      final me = await t.get(currentRef);

      final List followingList = me.data()?['followingList'] ?? [];
      if (followingList.contains(targetUid)) return;

      t.update(targetRef, {'followers': FieldValue.increment(1)});

      t.update(currentRef, {
        'following': FieldValue.increment(1),
        'followingList': FieldValue.arrayUnion([targetUid]),
      });

    });
    await onUserActivity(currentUid);
    await onUserActivity(targetUid);

  }

  Future<void> unfollow(String currentUid, String targetUid) async {
    final currentRef = _firestore.collection(usersCol).doc(currentUid);
    final targetRef = _firestore.collection(usersCol).doc(targetUid);

    await _firestore.runTransaction((t) async {
      t.update(targetRef, {'followers': FieldValue.increment(-1)});

      t.update(currentRef, {
        'following': FieldValue.increment(-1),
        'followingList': FieldValue.arrayRemove([targetUid]),
      });
    });
  }

  // ===============================
// FOLLOW REQUEST SYSTEM
// ===============================

  Future<void> sendFollowRequest(String fromUid, String toUid) async {
    await _firestore.collection("follow_requests").add({
      "from": fromUid,
      "to": toUid,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFollowRequest(String requestId, String fromUid, String toUid) async {
    final fromRef = _firestore.collection(usersCol).doc(fromUid);
    final toRef = _firestore.collection(usersCol).doc(toUid);

    await _firestore.runTransaction((t) async {
      t.update(fromRef, {
        "following": FieldValue.increment(1),
        "followingList": FieldValue.arrayUnion([toUid]),
      });

      t.update(toRef, {
        "followers": FieldValue.increment(1),
        "followersList": FieldValue.arrayUnion([fromUid]),
      });

      t.delete(_firestore.collection("follow_requests").doc(requestId));
    });
    await onUserActivity(fromUid);
    await onUserActivity(toUid);

  }

  Future<bool> hasPendingRequest(String fromUid, String toUid) async {
    final snap = await _firestore
        .collection("follow_requests")
        .where("from", isEqualTo: fromUid)
        .where("to", isEqualTo: toUid)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  // -------------------------------
  // Achievements
  // -------------------------------

  Future<void> grantAchievement(String uid, String achievement) async {
    final ref = _firestore.collection(usersCol).doc(uid);

    await ref.update({
      'achievements': FieldValue.arrayUnion([achievement]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===============================
// ACHIEVEMENTS ENGINE (CORE)
// ===============================

  Future<void> checkAndGrantAchievements(String uid) async {
    final ref = _firestore.collection(usersCol).doc(uid);
    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final List achievements = List<String>.from(data['achievements'] ?? []);

    void grant(String id) {
      if (!achievements.contains(id)) {
        achievements.add(id);
      }
    }

    final int portals = data['arSpotsCount'] ?? 0;
    final int followers = data['followers'] ?? 0;
    final int creations = data['creationsCount'] ?? 0;

    // 🌀 PORTALS
    if (portals >= 1) grant("first_portal");
    if (portals >= 10) grant("ten_portals");
    if (portals >= 50) grant("creator_50");

    // 👥 FOLLOWERS
    if (followers >= 1) grant("first_follower");
    if (followers >= 10) grant("followers_10");
    if (followers >= 100) grant("followers_100");

    // 🎨 OBJECTS
    if (creations >= 1) grant("first_object");

    // ⚡ ACTIVE CREATOR (baseline)
    if (portals >= 3 || creations >= 3) {
      grant("active_creator");
    }

    await ref.update({
      "achievements": achievements,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }


  // -------------------------------
  // Ensure user doc exists
  // -------------------------------

  Future<void> ensureUserDoc(String uid) async {
    final doc = await _firestore.collection(usersCol).doc(uid).get();

    if (!doc.exists) {
      final user = _auth.currentUser;
      if (user != null) {
        await createIfNotExist(user);
      }
    }
  }

  // -------------------------------
  // Update profile (WITHOUT username change)
  // -------------------------------

  Future<String?> fullUpdateProfile({
    required String uid,

    // basic info
    required String displayName,
    required String username,
    required String bio,

    // meta
    String? country,
    String? language,
    DateTime? birthDate,

    // social
    required Map<String, String> socialLinks,

    // privacy
    required bool isPrivate,

    // media files
    File? newAvatar,
    File? newCover,
  }) async {

    try {
      final userRef = _firestore.collection(usersCol).doc(uid);

      final userSnap = await userRef.get();
      final oldData = userSnap.data() ?? {};

      final oldUsername = (oldData['username'] ?? '').toString();
      final oldAvatar = (oldData['photoUrl'] ?? '').toString();
      final oldCover = (oldData['coverUrl'] ?? '').toString();

      // ---------- 1) username check ----------
      final cleanUsername = username.trim().toLowerCase();

      if (cleanUsername != oldUsername.toLowerCase()) {

        final exists =
        await _firestore.collection("usernames").doc(cleanUsername).get();

        if (exists.exists) {
          return "Username already taken";
        }

        // reserve new - delete old
        await _firestore.runTransaction((t) async {
          t.set(
              _firestore.collection("usernames").doc(cleanUsername),
              {"uid": uid}
          );

          if (oldUsername.isNotEmpty) {
            t.delete(
                _firestore.collection("usernames").doc(oldUsername.toLowerCase())
            );
          }
        });
      }

      // ---------- 2) upload media ----------
      String? avatarUrl = oldAvatar;
      String? coverUrl = oldCover;

      if (newAvatar != null) {
        avatarUrl = await uploadAvatar(uid, newAvatar, oldUrl: oldAvatar);
      }

      if (newCover != null) {
        coverUrl = await uploadCover(uid, newCover, oldUrl: oldCover);
      }

      // ---------- 3) update profile ----------
      await userRef.update({
        "displayName": displayName.trim(),
        "username": cleanUsername,
        "bio": bio.trim(),
        "country": country,
        "language": language,
        "birthDate": birthDate?.millisecondsSinceEpoch,
        "photoUrl": avatarUrl,
        "coverUrl": coverUrl,
        "socialLinks": socialLinks,
        "isPrivateProfile": isPrivate,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      await onUserActivity(uid);

      return null;
    } catch (e) {
      return e.toString();
    }
  }


  Future<String?> updateUserProfile({
    required String uid,
    required String displayName,
    required String bio,
    required Map<String, String> social,
    required bool isPrivate,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'displayName': displayName.trim(),
        'bio': bio.trim(),
        'social': social,
        'isPrivateProfile': isPrivate,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------------------
  // AR counter increment
  // -------------------------------

  Future<void> incrementARCounter(String uid, String field, int value) async {
    await _firestore.collection('users').doc(uid).update({
      field: FieldValue.increment(value),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  // ===============================
// PROFILE COMPLETION SCORE
// ===============================

  Future<int> calculateProfileCompletion(String uid) async {
    final ref = _firestore.collection(usersCol).doc(uid);
    final snap = await ref.get();
    if (!snap.exists) return 0;

    final d = snap.data()!;
    int score = 0;

    bool hasText(String? v) => v != null && v.trim().isNotEmpty;

    // 🧑 Basic Info
    if (hasText(d['username'])) score += 10;
    if (hasText(d['displayName'])) score += 5;
    if (hasText(d['bio'])) score += 10;
    if (hasText(d['photoUrl'])) score += 10;
    if (hasText(d['coverUrl'])) score += 5;

    // 🔗 Social Links
    final socials = Map<String, dynamic>.from(d['social'] ?? {});
    if (socials.values.any((v) => hasText(v))) score += 10;

    // 🌀 Activity
    final int portals = d['arSpotsCount'] ?? 0;
    if (portals >= 1) score += 15;
    if (portals >= 5) score += 10;

    final int followers = d['followers'] ?? 0;
    if (followers > 0) score += 10;

    // 🏆 Achievements
    final List ach = List.from(d['achievements'] ?? []);
    if (ach.isNotEmpty) score += 10;

    if (score > 100) score = 100;

    await ref.update({
      "profileCompletion": score,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return score;
  }


  Future<void> onUserActivity(String uid) async {
    await checkAndGrantAchievements(uid);
    await updateProfileCompletion(uid);
  }

  Future<void> updateProfileCompletion(String uid) async {
    await calculateProfileCompletion(uid);
  }

}
