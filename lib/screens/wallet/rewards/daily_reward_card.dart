// File: lib/screens/wallet/rewards/daily_reward_card.dart
// MetaZone — Daily Reward Card (LIVE + WALLET WIRED)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services & Models
import '../../../services/wallet/rewards_service.dart';
import '../../../services/wallet/wallet_service.dart';
import '../../../services/wallet/transactions_service.dart';
import '../../../models/wallet/reward_model.dart';
import '../../../models/wallet/transaction_model.dart';

class DailyRewardCard extends StatefulWidget {
  final RewardModel reward;
  final VoidCallback onClaim;

  const DailyRewardCard({
    super.key,
    required this.reward,
    required this.onClaim,
  });

  @override
  State<DailyRewardCard> createState() => _DailyRewardCardState();
}

class _DailyRewardCardState extends State<DailyRewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  final WalletService _wallet = WalletService.instance;
  final TransactionsService _tx = TransactionsService.instance;

  bool _loading = false;

  bool get _claimedToday {
    final d = widget.reward.availableAt;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year &&
        d.month == now.month &&
        d.day == now.day;
  }

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_claimedToday || _loading) return;

    setState(() => _loading = true);

    // 1️⃣ Add to wallet
    await _wallet.addFunds(widget.reward.rewardAmount);

    // 2️⃣ Add transaction
    await _tx.addTransaction(
      title: "Daily Reward",
      amount: widget.reward.rewardAmount,
      type: TransactionType.reward,
    );

    // 3️⃣ Update rewards service
    widget.onClaim();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "+${widget.reward.rewardAmount.toStringAsFixed(1)} MC earned 🎉",
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _claimedToday
              ? AppColors.primarySoft
              : AppColors.border.withOpacity(.35),
        ),
        boxShadow: _claimedToday
            ? [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.4),
            blurRadius: 20,
          )
        ]
            : [],
      ),
      child: Row(
        children: [
          // Icon
          ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.05).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.4),
                    blurRadius: 14,
                  )
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Reward",
                    style: AppTextStyles.title(size: 15)),
                const SizedBox(height: 4),
                Text(
                  "+${widget.reward.rewardAmount.toStringAsFixed(1)} MetaCredits",
                  style: AppTextStyles.caption()
                      .copyWith(color: AppColors.primarySoft),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Action
          _claimedToday
              ? _claimedBadge()
              : _claimButton(),
        ],
      ),
    );
  }

  Widget _claimButton() {
    return GestureDetector(
      onTap: _claimReward,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          ),
        )
            : Text(
          "Claim",
          style: AppTextStyles.caption(size: 13).copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _claimedBadge() {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withOpacity(.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Text(
        "Claimed ✔",
        style: AppTextStyles.caption(size: 12)
            .copyWith(color: AppColors.primarySoft),
      ),
    );
  }
}
