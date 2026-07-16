// File: lib/screens/wallet/widgets/rewards_preview.dart
// MetaZone Wallet — Rewards Preview Card (Neon Rewards UI)
// WIRED VERSION

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RewardsPreview extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  const RewardsPreview({
    super.key,
    this.onTap,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.card.withOpacity(.25),
          border: Border.all(
            color: AppColors.border.withOpacity(.35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.25),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // ⭐ Left: Reward Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daily Reward",
                    style: AppTextStyles.title(size: 16),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "Streak: 7 Days",
                    style: AppTextStyles.caption(size: 12)
                        .copyWith(color: Colors.white70),
                  ),

                  const SizedBox(height: 12),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 8,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                      backgroundColor: Colors.white.withOpacity(.15),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 18),

            // 🎁 CLAIM BUTTON
            GestureDetector(
              onTap: onClaim,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primarySoft.withOpacity(.45),
                      blurRadius: 24,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard,
                        size: 20, color: Colors.black),
                    const SizedBox(width: 6),
                    Text(
                      "Claim",
                      style: AppTextStyles.body(size: 14)
                          .copyWith(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
