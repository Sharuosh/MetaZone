import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class MetaTextField extends StatelessWidget {
  const MetaTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String? hintText;
  final String? labelText;

  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final bool obscureText;

  final bool enabled;

  final int maxLines;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTextStyles.body.copyWith(
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,

        filled: true,

        fillColor: AppColors.surface,

        prefixIcon: prefixIcon == null
            ? null
            : Icon(
          prefixIcon,
          color: AppColors.textSecondary,
        ),

        suffixIcon: suffixIcon,

        contentPadding: AppSpacing.button,

        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
        ),

        labelStyle: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.xxlRadius,
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.xxlRadius,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.xxlRadius,
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.xxlRadius,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}