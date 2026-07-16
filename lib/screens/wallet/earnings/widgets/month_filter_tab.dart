// File: lib/screens/wallet/earnings/widgets/month_filter_tab.dart
// MetaZone Wallet — Month Filter Tab (Neon Slider UI)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MonthFilterTab extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const MonthFilterTab({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      "Jan",
      "Dec",
      "Nov",
      "Oct",
      "Sep",
      "Aug",
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        padding: const EdgeInsets.only(right: 6),
        itemBuilder: (_, index) {
          final isActive = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isActive ? AppColors.neonGradient : null,
                color: !isActive
                    ? AppColors.card.withOpacity(.25)
                    : null,
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : AppColors.border.withOpacity(.4),
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color:
                    AppColors.primarySoft.withOpacity(.45),
                    blurRadius: 20,
                    spreadRadius: 1,
                  )
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  months[index],
                  style: AppTextStyles.caption(size: 12).copyWith(
                    color: isActive ? Colors.black : Colors.white70,
                    fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
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
