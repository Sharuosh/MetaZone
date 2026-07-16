// File: lib/screens/wallet/rewards/achievement_card.dart
// MetaZone — Achievement Card (LIVE WIRED VERSION)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../models/wallet/reward_model.dart';

class AchievementCard extends StatelessWidget {
  final RewardModel reward;

  const AchievementCard({
    super.key,
    required this.reward,
  });

  bool get _unlocked =>
      reward.status == RewardStatus.unlocked ||
          reward.status == RewardStatus.claimed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
        boxShadow: _unlocked
            ? [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.35),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          _icon(),
          const SizedBox(width: 16),
          _texts(),
        ],
      ),
    );
  }

  // =============================================================
  // ICON + UNLOCK STATE
  // =============================================================
  Widget _icon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: _unlocked
            ? AppColors.neonGradient
            : const LinearGradient(
          colors: [Color(0xFF444444), Color(0xFF2F2F2F)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _unlocked
            ? [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.45),
            blurRadius: 18,
          )
        ]
            : [],
      ),
      child: Icon(
        _unlocked ? Icons.emoji_events : Icons.lock_outline,
        color: _unlocked ? Colors.black : Colors.white54,
        size: 28,
      ),
    );
  }

  // =============================================================
  // TEXT + PROGRESS
  // =============================================================
  Widget _texts() {
    final progress = reward.progress.clamp(0.0, 1.0);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reward.title,
            style: AppTextStyles.title(size: 15),
          ),
          const SizedBox(height: 4),

          Text(
            reward.description,
            style: AppTextStyles.caption(size: 12)
                .copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 10),

          // PROGRESS BAR
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 8,
                width: progress * 200,
                decoration: BoxDecoration(
                  gradient: _unlocked
                      ? AppColors.neonGradient
                      : LinearGradient(
                    colors: [
                      AppColors.primarySoft,
                      AppColors.primarySoft.withOpacity(.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            _unlocked
                ? "Completed"
                : "${(progress * 100).toStringAsFixed(0)}% complete",
            style: AppTextStyles.caption(size: 11).copyWith(
              color:
              _unlocked ? AppColors.primarySoft : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
