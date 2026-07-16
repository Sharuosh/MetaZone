class ARWorldObject {
  final String id;
  final String title;
  final double lat;
  final double lng;
  final double x;
  final double y;

  double distanceKm;
  double scale;
  double opacity;
  bool visible;

  ARWorldObject({
    required this.id,
    required this.title,
    required this.lat,
    required this.lng,
    required this.x,
    required this.y,
    this.distanceKm = 0,
    this.scale = 1,
    this.opacity = 1,
    this.visible = true,
  });
}
