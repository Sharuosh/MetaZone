import 'package:flutter/material.dart';

import 'glass_container.dart';

enum GlassChipVariant {
  normal,
  primary,
  success,
  warning,
  danger,
}

enum GlassChipSize {
  small,
  medium,
  large,
}

class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,

    this.icon,
    this.trailingIcon,

    this.onTap,

    this.selected = false,
    this.enabled = true,

    this.variant = GlassChipVariant.normal,
    this.size = GlassChipSize.medium,

    this.badge,

    this.radius = 16,
  });

  final String label;

  final IconData? icon;

  final IconData? trailingIcon;

  final VoidCallback? onTap;

  final bool selected;

  final bool enabled;

  final GlassChipVariant variant;

  final GlassChipSize size;

  final String? badge;

  final double radius;

  Color get accent {
    switch (variant) {
      case GlassChipVariant.normal:
        return Colors.white;

      case GlassChipVariant.primary:
        return const Color(0xff5B8CFF);

      case GlassChipVariant.success:
        return const Color(0xff2ED47A);

      case GlassChipVariant.warning:
        return const Color(0xffFFB547);

      case GlassChipVariant.danger:
        return const Color(0xffFF5F7A);
    }
  }

  double get height {
    switch (size) {
      case GlassChipSize.small:
        return 36;

      case GlassChipSize.medium:
        return 44;

      case GlassChipSize.large:
        return 52;
    }
  }

  EdgeInsets get padding {
    switch (size) {
      case GlassChipSize.small:
        return const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        );

      case GlassChipSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        );

      case GlassChipSize.large:
        return const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        );
    }
  }

  double get fontSize {
    switch (size) {
      case GlassChipSize.small:
        return 13;

      case GlassChipSize.medium:
        return 14;

      case GlassChipSize.large:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(
        milliseconds: 220,
      ),
      opacity: enabled ? 1 : .45,
      child: GlassContainer(
        height: height,

        level: selected
            ? GlassLevel.strong
            : GlassLevel.normal,

        borderRadius: radius,

        padding: padding,

        onTap: enabled ? onTap : null,

        enableGlow: true,

        enableReflection: true,

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: selected
              ? [
            accent.withValues(
              alpha: .22,
            ),
            accent.withValues(
              alpha: .08,
            ),
          ]
              : [
            Colors.white.withValues(
              alpha: .08,
            ),
            Colors.white.withValues(
              alpha: .03,
            ),
          ],
        ),

        border: Border.all(
          color: accent.withValues(
            alpha: selected
                ? .55
                : .18,
          ),
          width: selected ? 1.5 : 1,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: fontSize,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w600,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(
                    alpha: .18,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    50,
                  ),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                trailingIcon,
                size: 18,
                color: accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}