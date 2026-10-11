import 'package:flutter/material.dart';

/// ===============================================================
/// MetaZone Typography System
/// ===============================================================
///
/// Central typography system for MetaZone.
///
/// Important:
/// This file intentionally supports both:
///
///   AppTextStyles.title
///   AppTextStyles.title(size: 16)
///
/// The second form exists for backward compatibility with existing
/// MetaZone screens while keeping the new typography system centralized.
/// ===============================================================

abstract final class AppTextStyles {
  AppTextStyles._();

  // ===============================================================
  // Fonts
  // ===============================================================

  static const String englishFont = 'Plus Jakarta Sans';
  static const String arabicFont = 'IBM Plex Sans Arabic';

  // ===============================================================
  // Core Typography
  // ===============================================================

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
    letterSpacing: -0.8,
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

  // ===============================================================
  // Title
  // ===============================================================

  static TextStyle title({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: size ?? 20,
      fontWeight: weight ?? FontWeight.w600,
      height: height ?? 1.25,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ===============================================================
  // Subtitle
  // ===============================================================

  static TextStyle subtitleStyle({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: size ?? 18,
      fontWeight: weight ?? FontWeight.w500,
      height: height ?? 1.35,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ===============================================================
  // Heading
  // ===============================================================
  //
  // Compatibility API used throughout the existing MetaZone UI.
  //

  static TextStyle heading({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: size ?? 24,
      fontWeight: weight ?? FontWeight.w700,
      height: height ?? 1.20,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ===============================================================
  // Body Large
  // ===============================================================

  static TextStyle bodyLargeStyle({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: size ?? 16,
      fontWeight: weight ?? FontWeight.w500,
      height: height ?? 1.50,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ===============================================================
  // Body
  // ===============================================================

  static TextStyle body({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: size ?? 15,
      fontWeight: weight ?? FontWeight.w400,
      height: height ?? 1.55,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ===============================================================
  // Body Small
  // ===============================================================

  static TextStyle bodySmallStyle({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: size ?? 14,
      fontWeight: weight ?? FontWeight.w400,
      height: height ?? 1.50,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ===============================================================
  // Labels
  // ===============================================================

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

  // ===============================================================
  // Button
  // ===============================================================

  static const TextStyle button = TextStyle(
    fontFamily: englishFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1,
  );

  // ===============================================================
  // Caption
  // ===============================================================

  static TextStyle caption({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: size ?? 11,
      fontWeight: weight ?? FontWeight.w400,
      height: height ?? 1.25,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ===============================================================
  // Micro
  // ===============================================================

  static const TextStyle micro = TextStyle(
    fontFamily: englishFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  // ===============================================================
  // Navigation
  // ===============================================================

  static const TextStyle navigation = TextStyle(
    fontFamily: englishFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // ===============================================================
  // AR / HUD
  // ===============================================================

  static const TextStyle hud = TextStyle(
    fontFamily: englishFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static const TextStyle arOverlay = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // ===============================================================
  // Backward Compatibility
  // ===============================================================

  static const TextStyle display = displayLarge;

  static const TextStyle displaySmall = displayMedium;

  static const TextStyle titleLarge = TextStyle(
    fontFamily: englishFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: englishFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle titleSmall = labelLarge;

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: englishFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyTiny = TextStyle(
    fontFamily: englishFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static const TextStyle overline = micro;
}