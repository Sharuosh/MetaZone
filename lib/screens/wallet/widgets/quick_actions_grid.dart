// File: lib/screens/wallet/widgets/quick_actions_grid.dart
// MetaZone Wallet — Quick Actions Grid (Neon Buttons 2025)
// FINAL FIXED VERSION — ALWAYS 6 ACTIONS ✅

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onAddFunds;
  final VoidCallback onWithdraw;
  final VoidCallback onTransactions;

  final VoidCallback? onEarnings;
  final VoidCallback? onRewards;
  final VoidCallback? onPaymentMethods;

  const QuickActionsGrid({
    super.key,
    required this.onAddFunds,
    required this.onWithdraw,
    required this.onTransactions,
    this.onEarnings,
    this.onRewards,
    this.onPaymentMethods,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        "icon": Icons.add_circle,
        "label": "Add Funds",
        "onTap": onAddFunds,
      },
      {
        "icon": Icons.credit_card,
        "label": "Payment Methods",
        "onTap": onPaymentMethods,
      },
      {
        "icon": Icons.arrow_circle_down,
        "label": "Withdraw",
        "onTap": onWithdraw,
      },
      {
        "icon": Icons.swap_vert_circle,
        "label": "Transactions",
        "onTap": onTransactions,
      },
      {
        "icon": Icons.monetization_on,
        "label": "Earnings",
        "onTap": onEarnings,
      },
      {
        "icon": Icons.stars_rounded,
        "label": "Rewards",
        "onTap": onRewards,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.card.withOpacity(.25),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.2),
            blurRadius: 18,
            spreadRadius: 1,
          )
        ],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: actions.map((a) {
          final VoidCallback? onTap = a["onTap"] as VoidCallback?;

          return GestureDetector(
            onTap: onTap ?? () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: AppColors.neonGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primarySoft.withOpacity(.45),
                        blurRadius: 22,
                      )
                    ],
                  ),
                  child: Icon(
                    a["icon"] as IconData,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  a["label"].toString(),
                  style: AppTextStyles.caption(size: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
