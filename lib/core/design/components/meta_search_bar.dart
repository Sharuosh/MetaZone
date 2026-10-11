import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class MetaSearchBar extends StatelessWidget {
  const MetaSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;

  final String hint;

  final bool autofocus;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTextStyles.body(
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(
          color: AppColors.textMuted,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            controller?.clear();
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppSpacing.button,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circleRadius,
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circleRadius,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}