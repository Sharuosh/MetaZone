import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class MetaBottomSheet extends StatelessWidget {
  const MetaBottomSheet({
    super.key,
    required this.child,
    this.padding = AppSpacing.allXL,
    this.showHandle = true,
  });

  final Widget child;

  final EdgeInsetsGeometry padding;

  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.topLarge,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                    AppRadius.circleRadius,
                  ),
                ),
                AppSpacing.gapLG,
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>(
      BuildContext context, {
        required Widget child,
        bool isScrollControlled = true,
        bool showHandle = true,
      }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      builder: (_) {
        return MetaBottomSheet(
          showHandle: showHandle,
          child: child,
        );
      },
    );
  }
}