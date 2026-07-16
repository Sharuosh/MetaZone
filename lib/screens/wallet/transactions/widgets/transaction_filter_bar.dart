// File: lib/screens/wallet/transactions/widgets/transaction_filter_bar.dart
// MetaZone Wallet — Transaction Filter Bar (Neon Tabs UI)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TransactionFilterBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const TransactionFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> _filters = const [
    "All",
    "Earnings",
    "Withdraw",
    "Deposit",
    "Purchases",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          bool active = i == selectedIndex;

          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: active ? AppColors.neonGradient : null,
                color:
                active ? null : AppColors.card.withOpacity(.22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : AppColors.border.withOpacity(.35),
                ),
                boxShadow: active
                    ? [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.5),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  _filters[i],
                  style: TextStyle(
                    fontSize: 13,
                    color: active ? Colors.black : AppColors.textSoft,
                    fontWeight: active ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
