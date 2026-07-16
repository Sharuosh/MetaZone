// File: lib/screens/wallet/add_funds/choose_amount_screen.dart
// MetaZone Wallet — Choose Amount Screen (Neon PRO 2025)
// FINAL WIRED VERSION (FIXED)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

import 'payment_confirmation_screen.dart';
import 'widgets/amount_option_card.dart';

class ChooseAmountScreen extends StatefulWidget {
  final String providerType;

  const ChooseAmountScreen({
    super.key,
    required this.providerType,
  });

  @override
  State<ChooseAmountScreen> createState() => _ChooseAmountScreenState();
}

class _ChooseAmountScreenState extends State<ChooseAmountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  int selectedIndex = -1;
  final TextEditingController customController = TextEditingController();

  final List<int> quickAmounts = [10, 25, 50, 100, 250, 500];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    customController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  int? _getSelectedAmount() {
    if (selectedIndex != -1) {
      return quickAmounts[selectedIndex];
    }

    final text = customController.text.trim();
    if (text.isEmpty) return null;

    final value = int.tryParse(text);
    if (value == null || value <= 0) return null;

    return value;
  }

  void _confirmPayment() {
    final amount = _getSelectedAmount();
    if (amount == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentConfirmationScreen(
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _getSelectedAmount();
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
                const SizedBox(height: 26),

                Text(
                  "Choose Amount",
                  style: AppTextStyles.title(size: 20),
                ),
                const SizedBox(height: 14),

                Expanded(child: _amountGrid()),
                const SizedBox(height: 20),

                _customAmountBox(),
                const SizedBox(height: 14),

                if (amount != null) _selectedAmountPreview(amount),
                const SizedBox(height: 20),

                _payButton(isEnabled),
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
              color: AppColors.card.withOpacity(.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(.35)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "Add with ${widget.providerType}",
          style: AppTextStyles.title(size: 18),
        ),
      ],
    );
  }

  // =============================================================
  // QUICK AMOUNTS GRID
  // =============================================================
  Widget _amountGrid() {
    return GridView.builder(
      itemCount: quickAmounts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) {
        final amount = quickAmounts[i];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = i;
              customController.clear();
            });
          },
          child: AmountOptionCard(
            amount: amount,
            active: selectedIndex == i,
          ),
        );
      },
    );
  }

  // =============================================================
  // CUSTOM AMOUNT INPUT
  // =============================================================
  Widget _customAmountBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: customController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) {
                setState(() {
                  selectedIndex = -1;
                });
              },
              decoration: const InputDecoration(
                hintText: "Enter custom amount",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SELECTED AMOUNT PREVIEW
  // =============================================================
  Widget _selectedAmountPreview(int amount) {
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
            "You will add $amount MC",
            style: AppTextStyles.title(size: 14),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CONTINUE BUTTON
  // =============================================================
  Widget _payButton(bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled ? _confirmPayment : null,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: isEnabled ? AppColors.neonGradient : null,
          color: !isEnabled ? AppColors.card.withOpacity(.25) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
          boxShadow: isEnabled
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
            isEnabled ? "Continue" : "Select amount",
            style: AppTextStyles.title(size: 16).copyWith(
              color: isEnabled ? Colors.black : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}
