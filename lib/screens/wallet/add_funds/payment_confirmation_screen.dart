// File: lib/screens/wallet/add_funds/payment_confirmation_screen.dart
// MetaZone Wallet — Payment Confirmation Screen (LIVE + PAYMENT METHOD WIRED)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services
import '../../../services/wallet/wallet_service.dart';
import '../../../services/wallet/transactions_service.dart';
import '../../../services/wallet/payment_service.dart';

// Models
import '../../../models/wallet/transaction_model.dart';
import '../../../models/wallet/payment_method_model.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final int amount;

  const PaymentConfirmationScreen({
    super.key,
    required this.amount,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _scale;

  final WalletService _wallet = WalletService.instance;
  final TransactionsService _tx = TransactionsService.instance;
  final PaymentService _payment = PaymentService.instance;

  PaymentMethodModel? _method;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scale = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOutBack,
    );

    Future.microtask(() async {
      final methods = await _payment.getPaymentMethods();
      if (!mounted) return;
      setState(() {
        _method = methods.isNotEmpty
            ? methods.firstWhere(
              (m) => m.isDefault,
          orElse: () => methods.first,
        )
            : null;
      });
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_loading || _method == null) return;

    setState(() => _loading = true);

    final paid = await _payment.processPayment(
      amount: widget.amount.toDouble(),
      method: _method!,
    );


    if (!paid) {
      setState(() => _loading = false);
      return;
    }

    await _wallet.addFunds(widget.amount.toDouble());

    await _tx.addTransaction(
      type: TransactionType.addFunds,
      amount: widget.amount.toDouble(),
      title: "Add Funds",
      description: _method!.providerName,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${widget.amount} MC added via ${_method!.providerName}",
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 40),
                _successIcon(),
                const SizedBox(height: 26),
                _paymentSummary(),
                const SizedBox(height: 30),
                _confirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(.4)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Text("Confirm Payment", style: AppTextStyles.title(size: 20)),
      ],
    );
  }

  Widget _successIcon() {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(80),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.5),
              blurRadius: 40,
            )
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 64,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _paymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Column(
        children: [
          _row(
            "Payment Method:",
            _method != null
                ? "${_method!.providerName} ${_method!.maskedNumber}"
                : "Not selected",
          ),
          const SizedBox(height: 12),
          _row("Amount:", "${widget.amount} MC"),
          const SizedBox(height: 12),
          _row("Fees:", "0.00 MC"),
          const Divider(height: 26, color: Colors.white24),
          _row("Total:", "${widget.amount} MC", highlight: true),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool highlight = false}) {
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
          style: AppTextStyles.title(size: highlight ? 18 : 15).copyWith(
            color: highlight ? AppColors.primarySoft : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _confirmButton() {
    return GestureDetector(
      onTap: _confirm,
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
            "Confirm & Add Funds",
            style: AppTextStyles.title(size: 16)
                .copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
