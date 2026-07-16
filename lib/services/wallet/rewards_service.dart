// File: lib/services/wallet/rewards_service.dart
// MetaZone — Rewards Service (CLEAN & ENTERPRISE READY)
// Handles: Daily Rewards, Achievements, Streaks
// Fully aligned with RewardModel (2025)

import 'dart:async';
import '../../models/wallet/reward_model.dart';

class RewardsService {
  // ============================================================
  // DAILY REWARD (MOCK)
  // ============================================================
  RewardModel _dailyReward = RewardModel(
    id: "daily_1",
    type: RewardType.daily,
    title: "Daily Login Bonus",
    description: "Come back every day to earn more MetaCredits.",
    icon: "assets/icons/reward.png",
    status: RewardStatus.unlocked,
    progress: 1.0,
    rewardAmount: 1.0,
    availableAt: null, // available now
  );

  // ============================================================
  // ACHIEVEMENTS (MOCK)
  // ============================================================
  final List<RewardModel> _achievements = [
    RewardModel(
      id: "ach_1",
      type: RewardType.achievement,
      title: "First AR Portal",
      description: "You created your first AR Portal!",
      icon: "assets/icons/trophy.png",
      status: RewardStatus.claimed,
      progress: 1.0,
      rewardAmount: 5.0,
      availableAt: DateTime(2025, 1, 20),
    ),
    RewardModel(
      id: "ach_2",
      type: RewardType.achievement,
      title: "Explorer Level 1",
      description: "Visited 10 AR Spots.",
      icon: "assets/icons/compass.png",
      status: RewardStatus.claimed,
      progress: 1.0,
      rewardAmount: 3.0,
      availableAt: DateTime(2025, 1, 21),
    ),
  ];

  // ============================================================
  // STREAK SYSTEM
  // ============================================================
  int _currentStreak = 3;

  // ============================================================
  // STREAMS
  // ============================================================
  final StreamController<RewardModel> _dailyRewardStream =
  StreamController<RewardModel>.broadcast();

  final StreamController<List<RewardModel>> _achievementStream =
  StreamController<List<RewardModel>>.broadcast();

  Stream<RewardModel> get dailyRewardStream => _dailyRewardStream.stream;
  Stream<List<RewardModel>> get achievementsStream =>
      _achievementStream.stream;

  // ============================================================
  // GET DAILY REWARD
  // ============================================================
  Future<RewardModel> getDailyReward() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _dailyReward;
  }

  // ============================================================
  // CLAIM DAILY REWARD
  // ============================================================
  Future<bool> claimDailyReward() async {
    await Future.delayed(const Duration(milliseconds: 350));

    // Already claimed today
    if (_dailyReward.status == RewardStatus.claimed &&
        _dailyReward.availableAt != null &&
        _isSameDay(_dailyReward.availableAt!, DateTime.now())) {
      return false;
    }

    _dailyReward = _dailyReward.copyWith(
      status: RewardStatus.claimed,
      availableAt: DateTime.now(),
    );

    _currentStreak++;

    _dailyRewardStream.add(_dailyReward);
    return true;
  }

  // ============================================================
  // STREAK
  // ============================================================
  Future<int> getCurrentStreak() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentStreak;
  }

  Future<void> resetStreak() async {
    _currentStreak = 0;
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================
  Future<List<RewardModel>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _achievements;
  }

  Future<void> addAchievement(RewardModel model) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _achievements.insert(0, model);
    _achievementStream.add(_achievements);
  }

  // ============================================================
  // UTIL
  // ============================================================
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ============================================================
  // DISPOSE
  // ============================================================
  void dispose() {
    _dailyRewardStream.close();
    _achievementStream.close();
  }
}
