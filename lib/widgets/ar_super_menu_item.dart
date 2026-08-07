// File: lib/widgets/ar_super_menu_item.dart

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class ARSuperMenuItem extends StatelessWidget {
  const ARSuperMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.bg,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient:
              bg == null ? AppColors.neonGradient : null,
              color: bg,
              borderRadius: AppRadius.lgRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withValues(
                    alpha: .18,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.black,
            ),
          ),

          AppSpacing.gapSM,

          SizedBox(
            width: 78,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.text,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}