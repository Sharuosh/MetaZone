// File: lib/screens/wallet/widgets/recent_transaction_item.dart
// MetaZone Wallet — Recent Transaction Item (Neon Glass UI)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RecentTransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final bool positive;

  const RecentTransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.card.withOpacity(.2),
        border: Border.all(
          color: AppColors.border.withOpacity(.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.4),
                  blurRadius: 16,
                )
              ],
            ),
            child: Icon(icon, size: 24, color: Colors.black),
          ),

          const SizedBox(width: 14),

          // Title + Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title(size: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style:
                  AppTextStyles.caption(size: 12).copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Amount (Positive or Negative)
          Text(
            amount,
            style: AppTextStyles.title(size: 14).copyWith(
              color: positive ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
