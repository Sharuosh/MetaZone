import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'design_token.dart';
import 'token.dart';

/// ---------------------------------------------------------------------------
/// Typography Token
/// ---------------------------------------------------------------------------

@immutable
class TypographyToken extends Token<TextStyle> {
  const TypographyToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.typography,
  );

  @override
  TypographyToken copyWith({
    String? name,
    TextStyle? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return TypographyToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  TextStyle get style => value;
}

/// ---------------------------------------------------------------------------
/// Font Families
/// ---------------------------------------------------------------------------

abstract final class FontFamilies {
  FontFamilies._();

  static const primary = 'SF Pro Display';

  static const secondary = 'SF Pro Text';

  static const mono = 'JetBrainsMono';

  static const display = 'SF Pro Rounded';
}

/// ---------------------------------------------------------------------------
/// Font Sizes
/// ---------------------------------------------------------------------------

abstract final class FontSizes {
  FontSizes._();

  static const s10 = 10.0;

  static const s12 = 12.0;

  static const s14 = 14.0;

  static const s16 = 16.0;

  static const s18 = 18.0;

  static const s20 = 20.0;

  static const s24 = 24.0;

  static const s28 = 28.0;

  static const s32 = 32.0;

  static const s40 = 40.0;

  static const s48 = 48.0;

  static const s56 = 56.0;

  static const s64 = 64.0;
}

/// ---------------------------------------------------------------------------
/// Font Weights
/// ---------------------------------------------------------------------------

abstract final class FontWeights {
  FontWeights._();

  static const thin = FontWeight.w100;

  static const extraLight = FontWeight.w200;

  static const light = FontWeight.w300;

  static const regular = FontWeight.w400;

  static const medium = FontWeight.w500;

  static const semiBold = FontWeight.w600;

  static const bold = FontWeight.w700;

  static const extraBold = FontWeight.w800;

  static const black = FontWeight.w900;
}
/// ---------------------------------------------------------------------------
/// Line Heights
/// ---------------------------------------------------------------------------

abstract final class LineHeights {
  LineHeights._();

  static const tight = 1.00;

  static const compact = 1.15;

  static const normal = 1.30;

  static const relaxed = 1.45;

  static const comfortable = 1.60;

  static const spacious = 1.80;

  static const loose = 2.00;
}

/// ---------------------------------------------------------------------------
/// Letter Spacing
/// ---------------------------------------------------------------------------

abstract final class LetterSpacings {
  LetterSpacings._();

  static const tighter = -1.20;

  static const tight = -.60;

  static const normal = 0.0;

  static const wide = .30;

  static const wider = .60;

  static const widest = 1.00;

  static const display = -1.50;
}

/// ---------------------------------------------------------------------------
/// Text Styles
/// ---------------------------------------------------------------------------

abstract final class TypographyStyles {
  TypographyStyles._();

  static const displayLarge = TextStyle(
    fontFamily: FontFamilies.display,
    fontSize: FontSizes.s64,
    fontWeight: FontWeights.black,
    height: LineHeights.tight,
    letterSpacing: LetterSpacings.display,
  );

  static const displayMedium = TextStyle(
    fontFamily: FontFamilies.display,
    fontSize: FontSizes.s56,
    fontWeight: FontWeights.extraBold,
    height: LineHeights.tight,
    letterSpacing: LetterSpacings.display,
  );

  static const displaySmall = TextStyle(
    fontFamily: FontFamilies.display,
    fontSize: FontSizes.s48,
    fontWeight: FontWeights.bold,
    height: LineHeights.compact,
    letterSpacing: LetterSpacings.tight,
  );

  static const headlineLarge = TextStyle(
    fontFamily: FontFamilies.primary,
    fontSize: FontSizes.s40,
    fontWeight: FontWeights.bold,
    height: LineHeights.compact,
  );

  static const headlineMedium = TextStyle(
    fontFamily: FontFamilies.primary,
    fontSize: FontSizes.s32,
    fontWeight: FontWeights.bold,
    height: LineHeights.normal,
  );

  static const headlineSmall = TextStyle(
    fontFamily: FontFamilies.primary,
    fontSize: FontSizes.s28,
    fontWeight: FontWeights.semiBold,
    height: LineHeights.normal,
  );

  static const titleLarge = TextStyle(
    fontFamily: FontFamilies.primary,
    fontSize: FontSizes.s24,
    fontWeight: FontWeights.semiBold,
    height: LineHeights.normal,
  );

  static const titleMedium = TextStyle(
    fontFamily: FontFamilies.primary,
    fontSize: FontSizes.s20,
    fontWeight: FontWeights.medium,
    height: LineHeights.relaxed,
  );

static const titleSmall = TextStyle(
  fontFamily: FontFamilies.primary,
  fontSize: FontSizes.s18,
  fontWeight: FontWeights.medium,
  height: LineHeights.relaxed,
);

static const bodyLarge = TextStyle(
  fontFamily: FontFamilies.secondary,
  fontSize: FontSizes.s18,
  fontWeight: FontWeights.regular,
  height: LineHeights.comfortable,
);

static const bodyMedium = TextStyle(
  fontFamily: FontFamilies.secondary,
  fontSize: FontSizes.s16,
  fontWeight: FontWeights.regular,
  height: LineHeights.comfortable,
);

static const bodySmall = TextStyle(
  fontFamily: FontFamilies.secondary,
  fontSize: FontSizes.s14,
  fontWeight: FontWeights.regular,
  height: LineHeights.relaxed,
);

static const labelLarge = TextStyle(
  fontFamily: FontFamilies.primary,
  fontSize: FontSizes.s16,
  fontWeight: FontWeights.medium,
  letterSpacing: LetterSpacings.wide,
);

static const labelMedium = TextStyle(
  fontFamily: FontFamilies.primary,
  fontSize: FontSizes.s14,
  fontWeight: FontWeights.medium,
  letterSpacing: LetterSpacings.wide,
);

static const labelSmall = TextStyle(
  fontFamily: FontFamilies.primary,
  fontSize: FontSizes.s12,
  fontWeight: FontWeights.medium,
  letterSpacing: LetterSpacings.wider,
);

static const caption = TextStyle(
  fontFamily: FontFamilies.secondary,
  fontSize: FontSizes.s12,
  fontWeight: FontWeights.regular,
  height: LineHeights.normal,
);

static const overline = TextStyle(
  fontFamily: FontFamilies.primary,
  fontSize: FontSizes.s10,
  fontWeight: FontWeights.semiBold,
  letterSpacing: LetterSpacings.widest,
);

static const code = TextStyle(
  fontFamily: FontFamilies.mono,
  fontSize: FontSizes.s14,
  fontWeight: FontWeights.regular,
  height: LineHeights.normal,
);
}

/// ---------------------------------------------------------------------------
/// Typography Tokens
/// ---------------------------------------------------------------------------

abstract final class TypographyTokens {
  TypographyTokens._();

  static final displayLarge = TypographyToken(
    name: 'typography.displayLarge',
    value: TypographyStyles.displayLarge,
  );

  static final displayMedium = TypographyToken(
    name: 'typography.displayMedium',
    value: TypographyStyles.displayMedium,
  );

  static final displaySmall = TypographyToken(
    name: 'typography.displaySmall',
    value: TypographyStyles.displaySmall,
  );

  static final headlineLarge = TypographyToken(
    name: 'typography.headlineLarge',
    value: TypographyStyles.headlineLarge,
  );

  static final headlineMedium = TypographyToken(
    name: 'typography.headlineMedium',
    value: TypographyStyles.headlineMedium,
  );

  static final headlineSmall = TypographyToken(
    name: 'typography.headlineSmall',
    value: TypographyStyles.headlineSmall,
  );

  static final titleLarge = TypographyToken(
    name: 'typography.titleLarge',
    value: TypographyStyles.titleLarge,
  );

  static final titleMedium = TypographyToken(
    name: 'typography.titleMedium',
    value: TypographyStyles.titleMedium,
  );

  static final titleSmall = TypographyToken(
    name: 'typography.titleSmall',
    value: TypographyStyles.titleSmall,
  );
  static final bodyLarge = TypographyToken(
    name: 'typography.bodyLarge',
    value: TypographyStyles.bodyLarge,
  );

  static final bodyMedium = TypographyToken(
    name: 'typography.bodyMedium',
    value: TypographyStyles.bodyMedium,
  );

  static final bodySmall = TypographyToken(
    name: 'typography.bodySmall',
    value: TypographyStyles.bodySmall,
  );

  static final labelLarge = TypographyToken(
    name: 'typography.labelLarge',
    value: TypographyStyles.labelLarge,
  );

  static final labelMedium = TypographyToken(
    name: 'typography.labelMedium',
    value: TypographyStyles.labelMedium,
  );

  static final labelSmall = TypographyToken(
    name: 'typography.labelSmall',
    value: TypographyStyles.labelSmall,
  );

  static final caption = TypographyToken(
    name: 'typography.caption',
    value: TypographyStyles.caption,
  );

  static final overline = TypographyToken(
    name: 'typography.overline',
    value: TypographyStyles.overline,
  );

  static final code = TypographyToken(
    name: 'typography.code',
    value: TypographyStyles.code,
  );

  static final List<TypographyToken> values = [
    displayLarge,
    displayMedium,
    displaySmall,
    headlineLarge,
    headlineMedium,
    headlineSmall,
    titleLarge,
    titleMedium,
    titleSmall,
    bodyLarge,
    bodyMedium,
    bodySmall,
    labelLarge,
    labelMedium,
    labelSmall,
    caption,
    overline,
    code,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

/// ---------------------------------------------------------------------------
/// Extensions
/// ---------------------------------------------------------------------------

extension TypographyTokenExtension on TypographyToken {
  TextStyle call({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return value.copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  TextStyle colored(Color color) {
    return value.copyWith(color: color);
  }

  TextStyle sized(double size) {
    return value.copyWith(fontSize: size);
  }

  TextStyle weighted(FontWeight weight) {
    return value.copyWith(fontWeight: weight);
  }

  TextStyle withHeight(double lineHeight) {
    return value.copyWith(height: lineHeight);
  }
}