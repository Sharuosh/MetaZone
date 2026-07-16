// File: lib/screens/wallet/withdraw/withdraw_screen.dart
// MetaZone Wallet — Withdraw Screen (Neon PRO 2025)
// FIXED & READY VERSION ✅

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

import 'choose_withdraw_method_screen.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  final TextEditingController _amountCtrl = TextEditingController();

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
    _amountCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  int? _getAmount() {
    final text = _amountCtrl.text.trim();
    if (text.isEmpty) return null;

    final value = int.tryParse(text);
    if (value == null || value <= 0) return null;

    return value;
  }

  void _openChooseMethod() {
    final amount = _getAmount();
    if (amount == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseWithdrawMethodScreen(
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _getAmount();
    final isEnabled = amount != null;

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
                const SizedBox(height: 30),

                Text(
                  "Withdraw Funds",
                  style: AppTextStyles.title(size: 22),
                ),
                const SizedBox(height: 10),

                Text(
                  "Enter the amount you want to withdraw from your wallet.",
                  style: AppTextStyles.caption(),
                ),
                const SizedBox(height: 30),

                _amountInput(),
                const SizedBox(height: 24),

                if (amount != null) _amountPreview(amount),
                const SizedBox(height: 30),

                _continueButton(isEnabled),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // TOP BAR
  // ===============================
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(.4)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Text("Withdraw", style: AppTextStyles.title(size: 20)),
      ],
    );
  }

  // ===============================
  // AMOUNT INPUT
  // ===============================
  Widget _amountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "Enter amount to withdraw",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
          Text("MC", style: AppTextStyles.title(size: 14)),
        ],
      ),
    );
  }

  // ===============================
  // AMOUNT PREVIEW
  // ===============================
  Widget _amountPreview(int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            "You will withdraw $amount MC",
            style: AppTextStyles.title(size: 14),
          ),
        ],
      ),
    );
  }

  // ===============================
  // CONTINUE BUTTON
  // ===============================
  Widget _continueButton(bool enabled) {
    return GestureDetector(
      onTap: enabled ? _openChooseMethod : null,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.neonGradient : null,
          color: !enabled ? AppColors.card.withOpacity(.25) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.4),
              blurRadius: 18,
            )
          ]
              : [],
        ),
        child: Center(
          child: Text(
            enabled ? "Continue" : "Enter amount",
            style: AppTextStyles.title(size: 16).copyWith(
              color: enabled ? Colors.black : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}
