// File: category_tab.dart
// MetaZone – Assets Panel Category Tab (Ultra PRO Edition)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class CategoryTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const CategoryTab({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? AppColors.neonGradient : null,
          color: !active ? AppColors.surface.withOpacity(.15) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? Colors.transparent
                : AppColors.border.withOpacity(.4),
          ),
          boxShadow: active
              ? [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.5),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? Colors.black : AppColors.textSoft,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.caption(size: 12).copyWith(
                color: active ? Colors.black : AppColors.textSoft,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
