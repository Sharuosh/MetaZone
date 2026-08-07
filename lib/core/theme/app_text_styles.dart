import 'package:flutter/material.dart';

/// ===============================================================
/// MetaZone Typography System
/// ===============================================================

abstract final class AppTextStyles {
  AppTextStyles._();

  static const String englishFont = 'Plus Jakarta Sans';
  static const String arabicFont = 'IBM Plex Sans Arabic';

  static const TextStyle displayXL = TextStyle(
    fontFamily: englishFont,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.4,
    height: 1.08,
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: englishFont,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.1,
    height: 1.10,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: englishFont,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -.8,
    height: 1.12,
  );

  static const TextStyle hero = TextStyle(
    fontFamily: englishFont,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: englishFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.20,
  );

  static const TextStyle title = TextStyle(
    fontFamily: englishFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: englishFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: englishFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.50,
  );

  static const TextStyle body = TextStyle(
    fontFamily: englishFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.50,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle label = TextStyle(
    fontFamily: englishFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: englishFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.20,
  );

  static const TextStyle button = TextStyle(
    fontFamily: englishFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: .2,
    height: 1,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: englishFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: englishFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  static const TextStyle navigation = TextStyle(
    fontFamily: englishFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle hud = TextStyle(
    fontFamily: englishFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: .8,
  );

  static const TextStyle arOverlay = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: .4,
  );
  // ===============================================================
  // Backward Compatibility
  // ===============================================================

  static const display = displayLarge;

  static const displaySmall = displayMedium;

  static const titleLarge = title;

  static const titleMedium = subtitle;

  static const titleSmall = labelLarge;

  static const bodyMedium = body;

  static const bodyTiny = caption;

  static const overline = micro;
}