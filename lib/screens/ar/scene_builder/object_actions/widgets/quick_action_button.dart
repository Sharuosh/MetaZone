// File: quick_action_button.dart
// MetaZone – Quick Action Button (Ultra PRO Edition)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: danger
              ? Colors.red.withOpacity(.12)
              : AppColors.surface.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: danger
                ? Colors.redAccent.withOpacity(.6)
                : AppColors.border.withOpacity(.35),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: danger ? Colors.redAccent : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption(size: 11).copyWith(
                color: danger ? Colors.redAccent : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
