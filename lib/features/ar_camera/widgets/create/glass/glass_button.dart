import 'package:flutter/material.dart';

import 'glass_container.dart';

enum GlassButtonVariant {
  primary,
  secondary,
  success,
  warning,
  danger,
  ghost,
}

enum GlassButtonSize {
  small,
  medium,
  large,
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.text,
    this.icon,
    this.iconTrailing,
    this.onPressed,
    this.width,
    this.variant = GlassButtonVariant.primary,
    this.size = GlassButtonSize.medium,
    this.loading = false,
    this.enabled = true,
    this.selected = false,
    this.hero = false,
  });

  final String text;

  final IconData? icon;

  final IconData? iconTrailing;

  final VoidCallback? onPressed;

  final double? width;

  final GlassButtonVariant variant;

  final GlassButtonSize size;

  final bool loading;

  final bool enabled;

  final bool selected;

  final bool hero;

  Color get _accent {
    switch (variant) {
      case GlassButtonVariant.primary:
        return const Color(0xff5B8CFF);

      case GlassButtonVariant.secondary:
        return Colors.white;

      case GlassButtonVariant.success:
        return const Color(0xff2ED47A);

      case GlassButtonVariant.warning:
        return const Color(0xffFFB547);

      case GlassButtonVariant.danger:
        return const Color(0xffFF5F7A);

      case GlassButtonVariant.ghost:
        return Colors.white70;
    }
  }

  double get _height {
    switch (size) {
      case GlassButtonSize.small:
        return 46;

      case GlassButtonSize.medium:
        return 56;

      case GlassButtonSize.large:
        return 66;
    }
  }

  double get _font {
    switch (size) {
      case GlassButtonSize.small:
        return 14;

      case GlassButtonSize.medium:
        return 16;

      case GlassButtonSize.large:
        return 18;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case GlassButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: 18,
        );

      case GlassButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: 22,
        );

      case GlassButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: 28,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clickable =
        enabled &&
            !loading &&
            onPressed != null;

    final accent = _accent;

    return AnimatedOpacity(
      duration: const Duration(
        milliseconds: 220,
      ),
      opacity: clickable ? 1 : .45,
      child: GlassContainer(
        width: width,
        height: _height,

        level: hero
            ? GlassLevel.hero
            : GlassLevel.normal,

        borderRadius: 18,

        padding: _padding,

        enableGlow: true,

        enableReflection: true,

        onTap:
        clickable
            ? onPressed
            : null,

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(
              alpha: hero ? .25 : .18,
            ),
            accent.withValues(
              alpha: .08,
            ),
          ],
        ),

        border: Border.all(
          color: accent.withValues(
            alpha: selected
                ? .55
                : .25,
          ),
          width: selected ? 1.5 : 1,
        ),

        child: Center(
          child: loading
              ? SizedBox(
            width: 22,
            height: 22,
            child:
            CircularProgressIndicator(
              strokeWidth: 2.3,
              valueColor:
              AlwaysStoppedAnimation(
                accent,
              ),
            ),
          )
              : Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: accent,
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
              Text(
                text,
                style: TextStyle(
                  color: accent,
                  fontSize: _font,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: .2,
                ),
              ),
              if (iconTrailing != null) ...[
                const SizedBox(
                  width: 10,
                ),
                Icon(
                  iconTrailing,
                  size: 20,
                  color: accent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}