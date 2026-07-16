// File: lib/screens/wallet/add_funds/add_funds_screen.dart
// MetaZone Wallet — Add Funds (Neon Glass PRO UI)
// WIRED & UX-CORRECT VERSION

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Next Screens
import 'choose_amount_screen.dart';

// Widgets
import '../payment_methods/widgets/payment_provider_icon.dart';

class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({super.key});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  String? _selectedProvider;

  final List<String> providers = [
    "Visa",
    "Mastercard",
    "PayPal",
    "Apple Pay",
    "Google Pay",
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

  void _continue() {
    if (_selectedProvider == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChooseAmountScreen(providerType: _selectedProvider!),
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

                _balanceBox(),
                const SizedBox(height: 28),

                Text(
                  "Select Payment Method",
                  style: AppTextStyles.title(size: 16),
                ),
                const SizedBox(height: 16),

                Expanded(child: _providersGrid()),

                const SizedBox(height: 18),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(.4)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Text("Add Funds", style: AppTextStyles.title(size: 22)),
      ],
    );
  }

  // =============================================================
  // BALANCE BOX
  // =============================================================
  Widget _balanceBox() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.5),
                  blurRadius: 18,
                )
              ],
            ),
            child: const Icon(Icons.account_balance_wallet,
                color: Colors.black, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Current Balance", style: AppTextStyles.caption()),
              const SizedBox(height: 4),
              Text("42.50 MC", style: AppTextStyles.title(size: 20)),
            ],
          )
        ],
      ),
    );
  }

  // =============================================================
  // PAYMENT PROVIDERS GRID
  // =============================================================
  Widget _providersGrid() {
    return GridView.builder(
      itemCount: providers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (_, i) {
        final type = providers[i];
        final selected = _selectedProvider == type;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedProvider = type;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withOpacity(.18)
                  : AppColors.card.withOpacity(.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.border.withOpacity(.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? AppColors.primarySoft.withOpacity(.35)
                      : AppColors.primarySoft.withOpacity(.15),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PaymentProviderIcon(type: type),
                const SizedBox(height: 12),
                Text(type, style: AppTextStyles.title(size: 15)),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // CONTINUE BUTTON
  // =============================================================
  Widget _continueButton() {
    final enabled = _selectedProvider != null;

    return GestureDetector(
      onTap: enabled ? _continue : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.neonGradient : null,
          color: enabled ? null : Colors.white.withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? AppColors.primary
                : Colors.white.withOpacity(.2),
          ),
        ),
        child: Center(
          child: Text(
            "Continue",
            style: AppTextStyles.title(size: 16).copyWith(
              color: enabled ? Colors.black : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}
