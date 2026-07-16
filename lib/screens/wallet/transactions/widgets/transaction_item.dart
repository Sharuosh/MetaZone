// File: lib/screens/wallet/transactions/widgets/transaction_item.dart
// MetaZone Wallet — Transaction Item (Neon Glass UI)
// CLEAN + WIRED VERSION

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TransactionItem extends StatelessWidget {
  final String id;          // transactionId
  final String title;       // Main label
  final String subtitle;    // Date
  final String amount;      // + 4.20 MC
  final bool positive;      // true = green, false = red
  final VoidCallback onTap; // Navigation handled by parent

  const TransactionItem({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.positive,
    required this.onTap,
  });

  IconData _getIcon() {
    if (title.toLowerCase().contains("withdraw")) {
      return Icons.arrow_upward_rounded;
    }
    if (title.toLowerCase().contains("add")) {
      return Icons.arrow_downward_rounded;
    }
    if (title.toLowerCase().contains("reward")) {
      return Icons.card_giftcard_rounded;
    }
    return Icons.shopping_bag_rounded;
  }

  Color _getColor() =>
      positive ? Colors.greenAccent : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.5),
                    blurRadius: 18,
                  )
                ],
              ),
              child: Icon(
                _getIcon(),
                color: Colors.black,
                size: 26,
              ),
            ),

            const SizedBox(width: 16),

            // Texts
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
                    subtitle,
                    style: AppTextStyles.caption(size: 12),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              amount,
              style: AppTextStyles.title(size: 14).copyWith(
                color: _getColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
