import 'package:flutter/material.dart';
import 'ar_interaction_engine.dart';

class ARGestureController {
  final ARInteractionEngine engine;

  ARGestureController({required this.engine});

  // =========================
  // TAP
  // =========================

  void onTap({
    required Offset position,
    required Size screenSize,
  }) {
    engine.handleTap(position, screenSize);
  }

  // =========================
  // DRAG
  // =========================

  void onPanStart() {
    engine.startDragging();
  }

  void onPanEnd() {
    engine.endGesture();
  }

  // =========================
  // SCALE
  // =========================

  void onScaleStart() {
    engine.startScaling();
  }

  void onScaleEnd() {
    engine.endGesture();
  }

  void onScaleUpdate(double scaleDelta) {
    // لاحقاً ممكن نربطه بالـ selected object transform
  }

  // =========================
  // ROTATE
  // =========================

  void onRotate(double delta) {
    // لاحقاً نضيف rotation handling
  }
}
