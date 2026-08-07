import 'package:flutter/widgets.dart';

/// ===============================================================
/// MetaZone Spacing System
/// 8pt Spatial Grid
/// ===============================================================

abstract final class AppSpacing {
  AppSpacing._();

  static const double none = 0;

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double giant = 56;
  static const double massive = 64;
  static const double colossal = 72;
  static const double ultra = 80;
  static const double infinity = 96;

  // Insets

  static const EdgeInsets zero = EdgeInsets.zero;

  static const EdgeInsets allXS = EdgeInsets.all(xs);
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  static const EdgeInsets allMD = EdgeInsets.all(md);
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  static const EdgeInsets allXL = EdgeInsets.all(xl);
  static const EdgeInsets allXXL = EdgeInsets.all(xxl);

  // Horizontal

  static const EdgeInsets horizontalXS =
  EdgeInsets.symmetric(horizontal: xs);

  static const EdgeInsets horizontalSM =
  EdgeInsets.symmetric(horizontal: sm);

  static const EdgeInsets horizontalMD =
  EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets horizontalLG =
  EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets horizontalXL =
  EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets horizontalXXL =
  EdgeInsets.symmetric(horizontal: xxl);

  // Vertical

  static const EdgeInsets verticalXS =
  EdgeInsets.symmetric(vertical: xs);

  static const EdgeInsets verticalSM =
  EdgeInsets.symmetric(vertical: sm);

  static const EdgeInsets verticalMD =
  EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets verticalLG =
  EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets verticalXL =
  EdgeInsets.symmetric(vertical: xl);

  static const EdgeInsets verticalXXL =
  EdgeInsets.symmetric(vertical: xxl);

  // Common Page Padding

  static const EdgeInsets screen =
  EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  static const EdgeInsets dialog =
  EdgeInsets.all(xl);

  static const EdgeInsets card =
  EdgeInsets.all(lg);

  static const EdgeInsets button =
  EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  // Gaps

  static const SizedBox gapXXS =
  SizedBox(height: xxs);

  static const SizedBox gapXS =
  SizedBox(height: xs);

  static const SizedBox gapSM =
  SizedBox(height: sm);

  static const SizedBox gapMD =
  SizedBox(height: md);

  static const SizedBox gapLG =
  SizedBox(height: lg);

  static const SizedBox gapXL =
  SizedBox(height: xl);

  static const SizedBox gapXXL =
  SizedBox(height: xxl);

  static const SizedBox gapXXXL =
  SizedBox(height: xxxl);

  static const SizedBox hGapXS =
  SizedBox(width: xs);

  static const SizedBox hGapSM =
  SizedBox(width: sm);

  static const SizedBox hGapMD =
  SizedBox(width: md);

  static const SizedBox hGapLG =
  SizedBox(width: lg);

  static const SizedBox hGapXL =
  SizedBox(width: xl);

  static const SizedBox hGapXXL =
  SizedBox(width: xxl);
}