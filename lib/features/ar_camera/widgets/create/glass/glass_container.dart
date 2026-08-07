import 'dart:ui';

import 'package:flutter/material.dart';

enum GlassLevel {
  subtle,
  normal,
  strong,
  hero,
  overlay,
}

extension GlassLevelExtension on GlassLevel {
  double get blur {
    switch (this) {
      case GlassLevel.subtle:
        return 12;

      case GlassLevel.normal:
        return 22;

      case GlassLevel.strong:
        return 30;

      case GlassLevel.hero:
        return 38;

      case GlassLevel.overlay:
        return 45;
    }
  }

  double get opacity {
    switch (this) {
      case GlassLevel.subtle:
        return .05;

      case GlassLevel.normal:
        return .08;

      case GlassLevel.strong:
        return .11;

      case GlassLevel.hero:
        return .14;

      case GlassLevel.overlay:
        return .18;
    }
  }

  double get borderOpacity {
    switch (this) {
      case GlassLevel.subtle:
        return .08;

      case GlassLevel.normal:
        return .14;

      case GlassLevel.strong:
        return .18;

      case GlassLevel.hero:
        return .24;

      case GlassLevel.overlay:
        return .30;
    }
  }

  double get shadowOpacity {
    switch (this) {
      case GlassLevel.subtle:
        return .06;

      case GlassLevel.normal:
        return .10;

      case GlassLevel.strong:
        return .14;

      case GlassLevel.hero:
        return .18;

      case GlassLevel.overlay:
        return .22;
    }
  }
}

class GlassContainer extends StatefulWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 28,
    this.level = GlassLevel.normal,
    this.blur,
    this.opacity,
    this.borderOpacity,
    this.shadowOpacity,
    this.alignment,
    this.gradient,
    this.border,
    this.boxShadow,
    this.color,
    this.onTap,
    this.duration = const Duration(milliseconds: 220),
    this.clipBehavior = Clip.antiAlias,
    this.enableHover = true,
    this.enableScaleAnimation = true,
    this.enableReflection = true,
    this.enableGlow = true,
    this.scaleOnPress = .985,
  });

  final Widget child;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final double borderRadius;

  final GlassLevel level;

  final double? blur;
  final double? opacity;
  final double? borderOpacity;
  final double? shadowOpacity;

  final AlignmentGeometry? alignment;

  final Gradient? gradient;

  final Border? border;

  final List<BoxShadow>? boxShadow;

  final Color? color;

  final VoidCallback? onTap;

  final Duration duration;

  final Clip clipBehavior;

  final bool enableHover;

  final bool enableScaleAnimation;

  final bool enableReflection;

  final bool enableGlow;

  final double scaleOnPress;

  @override
  State<GlassContainer> createState() =>
      _GlassContainerState();
}

class _GlassContainerState
    extends State<GlassContainer> {
  bool _hovered = false;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final blur =
        widget.blur ?? widget.level.blur;

    final opacity =
        widget.opacity ??
            widget.level.opacity;

    final borderOpacity =
        widget.borderOpacity ??
            widget.level.borderOpacity;

    final shadowOpacity =
        widget.shadowOpacity ??
            widget.level.shadowOpacity;

    final radius =
    BorderRadius.circular(
      widget.borderRadius,
    );

    Widget child = AnimatedScale(
      duration: widget.duration,
      scale: widget.enableScaleAnimation
          ? (_pressed
          ? widget.scaleOnPress
          : (_hovered ? 1.01 : 1))
          : 1,
      child: AnimatedContainer(
        duration: widget.duration,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: widget.boxShadow ??
              [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                    alpha: shadowOpacity,
                  ),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(
                    0,
                    18,
                  ),
                ),
              ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          clipBehavior:
          widget.clipBehavior,
          child: blur > 0
              ? BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
            ),
            child:
            _buildGlassContent(
              radius,
              opacity,
              borderOpacity,
            ),
          )
              : _buildGlassContent(
            radius,
            opacity,
            borderOpacity,
          ),
        ),
      ),
    );

    if (!widget.enableHover) {
      return child;
    }

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
          _pressed = false;
        });
      },
      child: child,
    );
  }
  Widget _buildGlassContent(
      BorderRadius radius,
      double opacity,
      double borderOpacity,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        splashColor:
        Colors.white.withValues(
          alpha: .05,
        ),
        highlightColor:
        Colors.transparent,
        onHighlightChanged: (value) {
          if (!widget.enableScaleAnimation) {
            return;
          }

          setState(() {
            _pressed = value;
          });
        },
        onTap: widget.onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: widget.color ??
                Colors.white.withValues(
                  alpha: opacity,
                ),

            gradient: widget.gradient,

            borderRadius: radius,

            border:
            widget.border ??
                Border.all(
                  color: Colors.white
                      .withValues(
                    alpha:
                    borderOpacity,
                  ),
                ),
          ),

          child: Stack(
            children: [
              if (widget.enableGlow)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        radius,
                        gradient:
                        RadialGradient(
                          radius: 1.4,
                          colors: [
                            Colors.white
                                .withValues(
                              alpha:
                              .035,
                            ),
                            Colors
                                .transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (widget.enableReflection)
                Positioned(
                  top: -60,
                  left: -30,
                  right: -30,
                  child: IgnorePointer(
                    child: Container(
                      height: 120,
                      decoration:
                      BoxDecoration(
                        gradient:
                        LinearGradient(
                          begin: Alignment
                              .topCenter,
                          end: Alignment
                              .bottomCenter,
                          colors: [
                            Colors.white
                                .withValues(
                              alpha: .12,
                            ),
                            Colors
                                .transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Container(
                alignment:
                widget.alignment,
                width: widget.width,
                height: widget.height,
                padding:
                widget.padding,
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}