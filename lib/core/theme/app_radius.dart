import 'package:flutter/widgets.dart';

/// ===============================================================
/// MetaZone Radius System
/// Spatial Glass Design
/// ===============================================================

abstract final class AppRadius {
  AppRadius._();

  static const double none = 0;

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;

  static const double pill = 999;
  static const double circle = 9999;

  // BorderRadius

  static const BorderRadius noneRadius =
      BorderRadius.zero;

  static const BorderRadius xsRadius =
  BorderRadius.all(
    Radius.circular(xs),
  );

  static const BorderRadius smRadius =
  BorderRadius.all(
    Radius.circular(sm),
  );

  static const BorderRadius mdRadius =
  BorderRadius.all(
    Radius.circular(md),
  );

  static const BorderRadius lgRadius =
  BorderRadius.all(
    Radius.circular(lg),
  );

  static const BorderRadius xlRadius =
  BorderRadius.all(
    Radius.circular(xl),
  );

  static const BorderRadius xxlRadius =
  BorderRadius.all(
    Radius.circular(xxl),
  );

  static const BorderRadius xxxlRadius =
  BorderRadius.all(
    Radius.circular(xxxl),
  );

  static const BorderRadius hugeRadius =
  BorderRadius.all(
    Radius.circular(huge),
  );

  static const BorderRadius giantRadius =
  BorderRadius.all(
    Radius.circular(giant),
  );

  static const BorderRadius pillRadius =
  BorderRadius.all(
    Radius.circular(pill),
  );

  static const BorderRadius circleRadius =
  BorderRadius.all(
    Radius.circular(circle),
  );

  // Top

  static const BorderRadius top =
  BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  static const BorderRadius topLarge =
  BorderRadius.vertical(
    top: Radius.circular(xxxl),
  );

  // Bottom

  static const BorderRadius bottom =
  BorderRadius.vertical(
    bottom: Radius.circular(xxl),
  );

  static const BorderRadius bottomLarge =
  BorderRadius.vertical(
    bottom: Radius.circular(xxxl),
  );

  // Left

  static const BorderRadius left =
  BorderRadius.horizontal(
    left: Radius.circular(xxl),
  );

  // Right

  static const BorderRadius right =
  BorderRadius.horizontal(
    right: Radius.circular(xxl),
  );
}