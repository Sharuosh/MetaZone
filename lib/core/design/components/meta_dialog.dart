import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'meta_button.dart';

class MetaDialog extends StatelessWidget {
  const MetaDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.confirmText = 'Continue',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;

  final IconData? icon;

  final String confirmText;
  final String cancelText;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.xxxlRadius,
      ),
      child: Padding(
        padding: AppSpacing.allXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 52,
                color: AppColors.primary,
              ),
              AppSpacing.gapLG,
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                color: AppColors.text,
              ),
            ),
            AppSpacing.gapMD,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.gapXL,
            MetaButton(
              expand: true,
              text: confirmText,
              onPressed: () {
                Navigator.pop(context);
                onConfirm?.call();
              },
            ),
            AppSpacing.gapSM,
            MetaButton(
              expand: true,
              text: cancelText,
              backgroundColor: AppColors.surfaceElevated,
              gradient: null,
              onPressed: () {
                Navigator.pop(context);
                onCancel?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}