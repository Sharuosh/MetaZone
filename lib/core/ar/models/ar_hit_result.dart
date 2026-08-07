import 'package:flutter/foundation.dart';

@immutable
class ARHitResult {
  const ARHitResult({
    required this.x,
    required this.y,
    required this.z,
    required this.distance,
    this.trackableId,
    this.isValid = true,
  });

  final double x;
  final double y;
  final double z;
  final double distance;
  final String? trackableId;
  final bool isValid;

  ARHitResult copyWith({
    double? x,
    double? y,
    double? z,
    double? distance,
    String? trackableId,
    bool? isValid,
  }) {
    return ARHitResult(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      distance: distance ?? this.distance,
      trackableId: trackableId ?? this.trackableId,
      isValid: isValid ?? this.isValid,
    );
  }
}