import 'package:flutter/material.dart';

import 'glass_container.dart';

enum GlassCardVariant {
  standard,
  hero,
  info,
  success,
  warning,
  danger,
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,

    this.width,
    this.height,

    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(8),

    this.radius = 28,

    this.level = GlassLevel.normal,

    this.variant = GlassCardVariant.standard,

    this.alignment,

    this.color,
    this.gradient,

    this.accentColor,

    this.selected = false,
    this.disabled = false,

    this.enableGlow = true,
    this.enableReflection = true,

    this.onTap,
  });

  final Widget child;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final double radius;

  final GlassLevel level;

  final GlassCardVariant variant;

  final AlignmentGeometry? alignment;

  final Color? color;

  final Gradient? gradient;

  final Color? accentColor;

  final bool selected;

  final bool disabled;

  final bool enableGlow;

  final bool enableReflection;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color? accent =
        accentColor ??
            switch (variant) {
              GlassCardVariant.standard => null,
              GlassCardVariant.hero => const Color(0xff6C63FF),
              GlassCardVariant.info => const Color(0xff4DA3FF),
              GlassCardVariant.success => const Color(0xff2ED47A),
              GlassCardVariant.warning => const Color(0xffFFB547),
              GlassCardVariant.danger => const Color(0xffFF5F7A),
            };

    final Gradient finalGradient =
        gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(
                  alpha: variant ==
                      GlassCardVariant.hero
                      ? .16
                      : .10,
                ),
                Colors.white.withValues(
                  alpha: .05,
                ),
              ],
            );

    return AnimatedOpacity(
      duration: const Duration(
        milliseconds: 220,
      ),
      opacity: disabled ? .45 : 1,
      child: Stack(
        children: [
          if (accent != null)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(
                      radius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        accent.withValues(
                          alpha: selected
                              ? .32
                              : .18,
                        ),
                        blurRadius: selected
                            ? 60
                            : 40,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          GlassContainer(
            width: width,
            height: height,

            margin: margin,
            padding: padding,

            borderRadius: radius,

            level: level,

            alignment: alignment,

            enableGlow:
            enableGlow,

            enableReflection:
            enableReflection,

            onTap:
            disabled
                ? null
                : onTap,

            gradient: finalGradient,

            border: Border.all(
              width: selected
                  ? 1.4
                  : 1,
              color: accent != null
                  ? accent.withValues(
                alpha: selected
                    ? .55
                    : .25,
              )
                  : Colors.white
                  .withValues(
                alpha: selected
                    ? .35
                    : .18,
              ),
            ),

            color:
            color ??
                Colors.white
                    .withValues(
                  alpha: .04,
                ),

            child: child,
          ),
        ],
      ),
    );
  }
}