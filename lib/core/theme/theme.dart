import 'package:flutter/material.dart';

import '../design/foundation/color_palette.dart';
import '../design/foundation/semantic_colors.dart';


import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

export 'app_colors.dart';
export 'app_gradients.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_text_styles.dart';

/// ===============================================================
/// MetaZone Theme
/// Spatial Glass Design Language
/// ===============================================================

abstract final class MetaZoneTheme {
  MetaZoneTheme._();

  static ThemeData dark() {
    final scheme = const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      colorScheme: scheme,

      scaffoldBackgroundColor: AppColors.background,

      canvasColor: AppColors.background,

      cardColor: AppColors.surface,

      dividerColor: AppColors.border,

      splashColor: Colors.transparent,

      highlightColor: Colors.transparent,

      disabledColor: AppColors.textDisabled,

      fontFamily: 'SF Pro Display',

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        color: AppColors.surface,
        shadowColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.xxlRadius,
        ),
      ),

      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        elevation: 8,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.lgRadius,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.xxxlRadius,
        ),
      ),
    );
  }

  static ThemeData light() {
    return dark().copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
    );
  }
}

/// Shortcut

typedef ThemeEngine = MetaZoneTheme;

/// Global access

typedef Palette = MetaPalette;

typedef ColorsX = SemanticColors;