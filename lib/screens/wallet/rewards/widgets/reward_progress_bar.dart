// File: lib/screens/wallet/rewards/widgets/reward_progress_bar.dart
// MetaZone — Reward Progress Bar (Neon Glow PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RewardProgressBar extends StatelessWidget {
  final double value; // from 0 → 1
  final String label;

  const RewardProgressBar({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.caption(size: 12).copyWith(
            color: AppColors.primarySoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // Progress Bar with glow
        Stack(
          children: [
            // Background bar
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Progress fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 10,
              width: (value.clamp(0, 1)) * 240,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
