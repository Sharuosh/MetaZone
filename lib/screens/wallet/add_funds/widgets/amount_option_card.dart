// File: lib/screens/wallet/add_funds/widgets/amount_option_card.dart
// MetaZone Wallet — Amount Option Card (Neon PRO 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class AmountOptionCard extends StatelessWidget {
  final int amount;
  final bool active;

  const AmountOptionCard({
    super.key,
    required this.amount,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: active ? AppColors.neonGradient : null,
        color:
        active ? null : AppColors.card.withOpacity(.22),
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
            blurRadius: 20,
            spreadRadius: 1,
          )
        ]
            : [],
      ),
      child: Center(
        child: Text(
          "$amount MC",
          style: AppTextStyles.title(size: 16).copyWith(
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
