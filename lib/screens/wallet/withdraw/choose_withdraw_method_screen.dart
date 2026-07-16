// File: lib/screens/wallet/withdraw/choose_withdraw_method_screen.dart
// MetaZone Wallet — Choose Withdraw Method (Neon PRO 2025)
// FINAL WIRED VERSION ✅ FIXED

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

import 'widgets/withdraw_method_card.dart';
import 'withdraw_confirmation_screen.dart';

class ChooseWithdrawMethodScreen extends StatefulWidget {
  final int amount;

  const ChooseWithdrawMethodScreen({
    super.key,
    required this.amount,
  });

  @override
  State<ChooseWithdrawMethodScreen> createState() =>
      _ChooseWithdrawMethodScreenState();
}

class _ChooseWithdrawMethodScreenState
    extends State<ChooseWithdrawMethodScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  int selected = -1;

  final List<Map<String, String>> methods = [
    {
      "title": "Bank Transfer",
      "subtitle": "International / Local",
      "icon": "assets/icons/bank.png"
    },
    {
      "title": "Vodafone Cash",
      "subtitle": "Egypt Wallet Transfer",
      "icon": "assets/icons/vodafone.png"
    },
    {
      "title": "PayPal",
      "subtitle": "Email-based transfer",
      "icon": "assets/icons/paypal.png"
    },
    {
      "title": "Crypto Wallet",
      "subtitle": "USDT / BTC / ETH",
      "icon": "assets/icons/crypto.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (selected == -1) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WithdrawConfirmationScreen(
          amount: widget.amount, // ✅ بس كده
        ),
      ),
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 26),

                Text(
                  "Choose Method",
                  style: AppTextStyles.title(size: 22),
                ),
                const SizedBox(height: 10),

                Text(
                  "Select how you would like to receive ${widget.amount} MC.",
                  style: AppTextStyles.caption(),
                ),
                const SizedBox(height: 30),

                Expanded(child: _methodsList()),
                const SizedBox(height: 20),

                _continueButton(),
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
              border: Border.all(color: AppColors.border.withOpacity(.35)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Text("Withdraw", style: AppTextStyles.title(size: 20)),
      ],
    );
  }

  // =============================================================
  // METHODS LIST
  // =============================================================
  Widget _methodsList() {
    return ListView.separated(
      itemCount: methods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final m = methods[i];

        return GestureDetector(
          onTap: () => setState(() => selected = i),
          child: WithdrawMethodCard(
            title: m["title"]!,
            subtitle: m["subtitle"]!,
            iconPath: m["icon"]!,
            active: i == selected,
          ),
        );
      },
    );
  }

  // =============================================================
  // CONTINUE BUTTON
  // =============================================================
  Widget _continueButton() {
    final bool enabled = selected != -1;

    return GestureDetector(
      onTap: enabled ? _goNext : null,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.neonGradient : null,
          color: enabled ? null : AppColors.card.withOpacity(.2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.4),
              blurRadius: 20,
            )
          ]
              : [],
        ),
        child: Center(
          child: Text(
            enabled ? "Continue" : "Select a method",
            style: AppTextStyles.title(size: 16).copyWith(
              color: enabled ? Colors.black : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}
