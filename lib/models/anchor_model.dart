class AnchorModel {
  // ===============================
  // Core Data (Stored in backend)
  // ===============================
  String id;
  String title;
  String description;
  double lat;
  double lng;
  DateTime createdAt;
  bool pinned;
  String owner;
  double stability;

  // ===============================
  // Runtime AR Rendering State
  // (NOT stored in backend)
  // ===============================
  double distanceMeters;
  double screenX;     // 0.0 → 1.0 (normalized)
  double screenY;     // 0.0 → 1.0
  double scale;       // visual size
  double opacity;     // visibility
  bool isVisible;     // inside camera-icon FOV

  AnchorModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.lat,
    required this.lng,
    DateTime? createdAt,
    this.pinned = false,
    this.owner = 'You',
    this.stability = 0.75,

    // Runtime defaults
    this.distanceMeters = 0.0,
    this.screenX = 0.5,
    this.screenY = 0.5,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.isVisible = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // ===============================
  // Backend Serialization
  // ===============================
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'lat': lat,
    'lng': lng,
    'createdAt': createdAt.toIso8601String(),
    'pinned': pinned,
    'owner': owner,
    'stability': stability,
  };

  factory AnchorModel.fromJson(Map<String, dynamic> json) {
    return AnchorModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      lat: json['lat'],
      lng: json['lng'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      pinned: json['pinned'] ?? false,
      owner: json['owner'] ?? 'Unknown',
      stability: (json['stability'] ?? 0.75).toDouble(),
    );
  }
}
