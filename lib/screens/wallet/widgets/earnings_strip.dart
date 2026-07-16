// File: lib/screens/wallet/widgets/earnings_strip.dart
// MetaZone Wallet — Earnings Summary Strip (2025 Neon UI)
// WIRED VERSION

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EarningsStrip extends StatelessWidget {
  final VoidCallback? onTap;

  const EarningsStrip({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.card.withOpacity(.25),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.2),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _item(
              label: "This Month",
              value: "+ 24.50",
              color: AppColors.primary,
            ),
            _divider(),
            _item(
              label: "Total Earned",
              value: "310.70",
              color: Colors.white,
            ),
            _divider(),
            _item(
              label: "Transactions",
              value: "58",
              color: Colors.white,
            ),
            _divider(),
            _item(
              label: "Growth",
              value: "+12%",
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(size: 11)
              .copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.title(size: 14).copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 26,
      color: Colors.white.withOpacity(.15),
    );
  }
}
