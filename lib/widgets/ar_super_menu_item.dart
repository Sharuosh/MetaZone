// File: lib/widgets/ar_super_menu_item.dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class ARSuperMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? bg;

  const ARSuperMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: bg != null ? null : AppColors.neonGradient,
              color: bg ?? null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.18),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black, size: 30),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 78,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(size: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
