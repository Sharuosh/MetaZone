import 'package:flutter/material.dart';

/// ===============================================================
/// MetaZone Elevation System
/// ===============================================================

abstract final class ElevationSystem {
  ElevationSystem._();

  static const double none = 0;

  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 12;
  static const double xxl = 16;
  static const double floating = 24;

  static const List<BoxShadow> noneShadow = [];
}