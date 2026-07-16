// File: lib/screens/wallet/rewards/rewards_screen.dart
// MetaZone Wallet — Rewards Screen (LIVE WIRED VERSION)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services & Models
import '../../../services/wallet/rewards_service.dart';
import '../../../models/wallet/reward_model.dart';

// Widgets
import 'daily_reward_card.dart';
import 'achievement_card.dart';
import 'widgets/reward_progress_bar.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  final RewardsService _rewards = RewardsService();

  RewardModel? _dailyReward;
  List<RewardModel> _achievements = [];
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _loadData();
  }

  Future<void> _loadData() async {
    final daily = await _rewards.getDailyReward();
    final achievements = await _rewards.getAchievements();
    final streak = await _rewards.getCurrentStreak();

    if (!mounted) return;
    setState(() {
      _dailyReward = daily;
      _achievements = achievements;
      _streakDays = streak;
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                _topBar(),
                const SizedBox(height: 20),

                _pointsHeader(),
                const SizedBox(height: 18),

                _streakSection(),
                const SizedBox(height: 28),

                Text("Daily Rewards",
                    style: AppTextStyles.title(size: 16)),
                const SizedBox(height: 10),

                if (_dailyReward != null)
                  DailyRewardCard(
                    reward: _dailyReward!,
                    onClaim: () async {
                      final success =
                      await _rewards.claimDailyReward();
                      if (success) {
                        await _loadData();
                      }
                    },
                  ),

                const SizedBox(height: 26),

                Text("Achievements",
                    style: AppTextStyles.title(size: 16)),
                const SizedBox(height: 10),

                _achievementsList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // TOP BAR
  // =============================================================
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.22),
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: AppColors.border.withOpacity(.35)),
            ),
            child:
            const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Text("Rewards",
            style: AppTextStyles.title(size: 20)),
        const Spacer(),
        Icon(Icons.stars_rounded,
            size: 30, color: AppColors.primarySoft),
      ],
    );
  }

  // =============================================================
  // POINTS HEADER
  // =============================================================
  Widget _pointsHeader() {
    final totalPoints = _achievements
        .where((a) => a.status == RewardStatus.claimed)
        .fold<double>(0, (s, a) => s + a.rewardAmount)
        .toInt() +
        (_dailyReward?.status == RewardStatus.claimed
            ? _dailyReward!.rewardAmount.toInt()
            : 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.neonGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.4),
            blurRadius: 24,
          )
        ],
      ),
      child: Column(
        children: [
          Text("Total Reward Points",
              style: AppTextStyles.caption(size: 13)
                  .copyWith(color: Colors.black87)),
          const SizedBox(height: 6),
          Text(
            "$totalPoints",
            style: AppTextStyles.title(size: 34)
                .copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // STREAK SECTION
  // =============================================================
  Widget _streakSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(18),
        border:
        Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Daily Streak",
              style: AppTextStyles.title(size: 16)),
          const SizedBox(height: 6),
          RewardProgressBar(
            value: (_streakDays % 7) / 7,
            label: "$_streakDays Days",
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ACHIEVEMENTS LIST
  // =============================================================
  Widget _achievementsList() {
    if (_achievements.isEmpty) {
      return Text(
        "No achievements yet",
        style: AppTextStyles.caption(),
      );
    }

    return Column(
      children: _achievements
          .map(
            (a) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AchievementCard(reward: a),
        ),
      )
          .toList(),
    );
  }
}
