// File: lib/screens/wallet/earnings/widgets/earnings_tile.dart
// MetaZone Wallet — Earnings Tile (Neon Glass Item)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EarningsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final bool positive;

  const EarningsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.positive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card.withOpacity(.22),
        border: Border.all(color: AppColors.border.withOpacity(.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 14,
          )
        ],
      ),
      child: Row(
        children: [
          // LEFT ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.35),
                  blurRadius: 18,
                )
              ],
            ),
            child: Icon(icon, color: Colors.black, size: 22),
          ),

          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title(size: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.caption(size: 12)
                        .copyWith(color: AppColors.textSoft)),
              ],
            ),
          ),

          // AMOUNT
          Text(
            "${positive ? "+" : "-"}$amount",
            style: AppTextStyles.title(size: 14).copyWith(
              color: positive ? AppColors.primary : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
