import 'package:cloud_firestore/cloud_firestore.dart';

class SavedSpot {
  final String id;
  final String title;
  final String creatorName;
  final String? coverUrl;
  final double? lat;
  final double? lng;
  final bool featured;
  final int likes;
  final DateTime savedAt;

  SavedSpot({
    required this.id,
    required this.title,
    required this.creatorName,
    required this.coverUrl,
    this.lat,
    this.lng,
    this.likes = 0,
    this.featured = false,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "creatorName": creatorName,
    "coverUrl": coverUrl,
    "lat": lat,
    "lng": lng,
    "likes": likes,
    "featured": featured,
    "savedAt": savedAt,
  };

  factory SavedSpot.fromFirestore(Map<String, dynamic> json, String id) {
    return SavedSpot(
      id: id,
      title: json["title"],
      creatorName: json["creatorName"],
      coverUrl: json["coverUrl"],
      lat: json["lat"],
      lng: json["lng"],
      likes: json["likes"] ?? 0,
      featured: json["featured"] ?? false,
      savedAt: (json["savedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
