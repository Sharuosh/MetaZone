// File: lib/screens/wallet/withdraw/widgets/withdraw_method_card.dart
// MetaZone Wallet — Withdraw Method Card (Neon Glass PRO 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class WithdrawMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final bool active;

  const WithdrawMethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: active ? AppColors.neonGradient : null,
        color: active ? null : AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? Colors.transparent
              : AppColors.border.withOpacity(.4),
        ),
        boxShadow: active
            ? [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.5),
            blurRadius: 24,
            spreadRadius: 1,
          )
        ]
            : [],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active
                  ? Colors.black.withOpacity(.1)
                  : AppColors.surface.withOpacity(.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(iconPath, fit: BoxFit.contain),
          ),

          const SizedBox(width: 14),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title(size: 16).copyWith(
                    color: active ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(size: 12).copyWith(
                    color: active ? Colors.black87 : Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Checkmark
          AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(
              Icons.check_circle,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
