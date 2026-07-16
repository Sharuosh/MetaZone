// File: lib/screens/wallet/withdraw/withdraw_confirmation_screen.dart
// MetaZone Wallet — Withdraw Confirmation Screen (LIVE + PAYMENT METHOD WIRED)
// FIXED & ALIGNED VERSION ✅

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services
import '../../../services/wallet/wallet_service.dart';
import '../../../services/wallet/transactions_service.dart';
import '../../../services/wallet/payment_service.dart';

// Models
import '../../../models/wallet/transaction_model.dart';
import '../../../models/wallet/payment_method_model.dart';

class WithdrawConfirmationScreen extends StatefulWidget {
  final int amount;

  const WithdrawConfirmationScreen({
    super.key,
    required this.amount,
  });

  @override
  State<WithdrawConfirmationScreen> createState() =>
      _WithdrawConfirmationScreenState();
}

class _WithdrawConfirmationScreenState
    extends State<WithdrawConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  final WalletService _wallet = WalletService.instance;
  final TransactionsService _tx = TransactionsService.instance;
  final PaymentService _payment = PaymentService.instance;

  static const double _feeRate = 0.02; // 2%

  PaymentMethodModel? _method;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _payment.init();
    _method = _payment.defaultMethod;
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmWithdraw() async {
    if (_loading) return;

    if (_method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No withdrawal method available"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final double total = widget.amount.toDouble();
    final double fee = total * _feeRate;
    final double received = total - fee;

    // 1️⃣ Withdraw from wallet
    final success = await _wallet.withdraw(total);
    if (!success) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient balance"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2️⃣ Record transaction
    await _tx.addTransaction(
      type: TransactionType.withdraw,
      amount: -total,
      title: "Withdraw Funds",
      description: _method!.providerName,
    );

    if (!mounted) return;

    // 3️⃣ Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Withdrawal of ${received.toStringAsFixed(2)} MC sent via ${_method!.providerName} 💸",
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 600));

    // 4️⃣ Back to Wallet Home
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double fee = widget.amount * _feeRate;
    final double received = widget.amount - fee;

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
                  "Confirm Withdrawal",
                  style: AppTextStyles.title(size: 22),
                ),
                const SizedBox(height: 10),

                Text(
                  "Review your withdrawal details before confirming.",
                  style: AppTextStyles.caption(),
                ),
                const SizedBox(height: 20),

                _methodChip(),
                const SizedBox(height: 26),

                _summaryBox(fee, received),
                const SizedBox(height: 30),

                _confirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // UI
  // =============================================================

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

  Widget _methodChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.neonGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        _method != null
            ? "${_method!.providerName} ${_method!.maskedNumber}"
            : "No Method",
        style:
        AppTextStyles.title(size: 14).copyWith(color: Colors.black),
      ),
    );
  }

  Widget _summaryBox(double fee, double received) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Column(
        children: [
          _summaryRow("Withdrawal Amount:", "${widget.amount} MC"),
          const SizedBox(height: 10),
          _summaryRow(
            "Platform Fee (2%):",
            "-${fee.toStringAsFixed(2)} MC",
          ),
          const Divider(height: 26, color: Colors.white24),
          _summaryRow(
            "You Will Receive:",
            "${received.toStringAsFixed(2)} MC",
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value,
      {bool highlight = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.caption(size: 13)
                .copyWith(color: Colors.white70),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.title(size: highlight ? 18 : 15)
              .copyWith(
            color: highlight
                ? AppColors.primarySoft
                : Colors.white,
          ),
        )
      ],
    );
  }

  Widget _confirmButton() {
    return GestureDetector(
      onTap: _confirmWithdraw,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.4),
              blurRadius: 20,
            )
          ],
        ),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          )
              : Text(
            "Confirm Withdraw",
            style: AppTextStyles.title(size: 16)
                .copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
