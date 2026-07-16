import 'dart:math';
import 'package:flutter/material.dart';

class ARHitResult {
  final Offset screenPosition;
  final Offset normalizedPosition;
  final double depth;
  final bool isValid;

  ARHitResult({
    required this.screenPosition,
    required this.normalizedPosition,
    required this.depth,
    required this.isValid,
  });
}

class ARHitTestService {

  /// Performs a screen-space hit test
  /// This is placeholder logic until Unity/ARCore world raycast is connected.
  ARHitResult hitTest({
    required Offset tapPosition,
    required Size screenSize,
  }) {
    // 1️⃣ Clamp to screen bounds
    final dx = tapPosition.dx.clamp(0.0, screenSize.width);
    final dy = tapPosition.dy.clamp(0.0, screenSize.height);

    final screenOffset = Offset(dx, dy);

    // 2️⃣ Normalize to viewport (0 → 1)
    final normalized = Offset(
      dx / screenSize.width,
      dy / screenSize.height,
    );

    // 3️⃣ Fake depth simulation (center = closer)
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    final distanceFromCenter =
        (screenOffset - center).distance;

    final maxDistance =
    sqrt(pow(screenSize.width / 2, 2) + pow(screenSize.height / 2, 2));

    final depth = 1 - (distanceFromCenter / maxDistance);

    return ARHitResult(
      screenPosition: screenOffset,
      normalizedPosition: normalized,
      depth: depth.clamp(0.0, 1.0),
      isValid: true,
    );
  }
}
