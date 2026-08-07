import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// ===============================================================
/// MetaZone Button
/// Spatial Glass Design
/// ===============================================================

class MetaButton extends StatelessWidget {
  const MetaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 54,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.loading = false,
    this.enabled = true,
    this.expand = false,
  });

  final String text;

  final VoidCallback? onPressed;

  final IconData? icon;

  final double? width;

  final double height;

  final Gradient? gradient;

  final Color? backgroundColor;

  final Color foregroundColor;

  final bool loading;

  final bool enabled;

  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: expand ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor ?? AppColors.primary : null,
        gradient: gradient ?? AppGradients.primary,
        borderRadius: AppRadius.xxlRadius,
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.xxlRadius,
          onTap: enabled && !loading ? onPressed : null,
          child: Padding(
            padding: AppSpacing.button,
            child: Center(
              child: loading
                  ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: foregroundColor,
                      size: 20,
                    ),
                    AppSpacing.hGapSM,
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : .45,
      child: button,
    );
  }
}