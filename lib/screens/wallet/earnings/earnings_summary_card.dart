// File: lib/screens/wallet/earnings/earnings_summary_card.dart
// MetaZone Wallet — Earnings Summary Card (Neon Glass UI)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class EarningsSummaryCard extends StatelessWidget {
  const EarningsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.card.withOpacity(.22),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.22),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("This Month",
              style: AppTextStyles.caption(size: 12)
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: 6),

          Text("+ 24.50 MC",
              style: AppTextStyles.title(size: 26)
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          Row(
            children: [
              _metric(
                label: "Year Total",
                value: "310.70",
              ),
              const Spacer(),
              _metric(
                label: "Growth",
                value: "+12%",
                color: Colors.greenAccent,
              ),
              const Spacer(),
              _metric(
                label: "Sales",
                value: "18",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric({
    required String label,
    required String value,
    Color color = Colors.white,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption(size: 11)
                .copyWith(color: Colors.white60)),
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
}
