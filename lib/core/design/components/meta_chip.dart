import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';

class MetaChip extends StatelessWidget {
  const MetaChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.padding =
    const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 10,
    ),
  });

  final String label;

  final IconData? icon;

  final bool selected;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? AppColors.primary
        : AppColors.surface;

    final foreground = selected
        ? Colors.white
        : AppColors.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.circleRadius,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 220,
          ),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: background,
            borderRadius:
            AppRadius.circleRadius,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: foreground,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}