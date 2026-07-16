class UserProfile {
  final String uid;
  final String metaId;
  final String username;
  final String displayName;
  final String bio;
  final String photoUrl;

  final bool verified;

  final int xp;
  final int level;
  final List<String> badges;

  final int followersCount;
  final int followingCount;

  final int arSpotsCount;
  final int creationsCount;
  final int mediaCount;

  final Map<String, dynamic> socialLinks;

  final bool isPrivateProfile;

  UserProfile({
    required this.uid,
    required this.metaId,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.photoUrl,
    required this.verified,
    required this.xp,
    required this.level,
    required this.badges,
    required this.followersCount,
    required this.followingCount,
    required this.arSpotsCount,
    required this.creationsCount,
    required this.mediaCount,
    required this.socialLinks,
    required this.isPrivateProfile,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      metaId: data['metaId'] ?? '',
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      verified: data['verified'] ?? false,
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      badges: List<String>.from(data['badges'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      arSpotsCount: data['arSpotsCount'] ?? 0,
      creationsCount: data['creationsCount'] ?? 0,
      mediaCount: data['mediaCount'] ?? 0,
      socialLinks: data['socialLinks'] ?? {},
      isPrivateProfile: data['isPrivateProfile'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "metaId": metaId,
      "username": username,
      "displayName": displayName,
      "bio": bio,
      "photoUrl": photoUrl,
      "verified": verified,
      "xp": xp,
      "level": level,
      "badges": badges,
      "followersCount": followersCount,
      "followingCount": followingCount,
      "arSpotsCount": arSpotsCount,
      "creationsCount": creationsCount,
      "mediaCount": mediaCount,
      "socialLinks": socialLinks,
      "isPrivateProfile": isPrivateProfile,
    };
  }
}
