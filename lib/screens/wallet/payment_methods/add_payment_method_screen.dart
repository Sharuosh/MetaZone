// File: lib/screens/wallet/payment_methods/add_payment_method_screen.dart
// MetaZone Wallet — Add Payment Method (Neon Glass PRO UI)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'widgets/payment_provider_icon.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  String selectedType = "Visa";

  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  final _paypalEmailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 22),

              _providerSelector(),
              const SizedBox(height: 22),

              if (_isCard(selectedType)) _cardForm(),
              if (selectedType.toLowerCase() == "paypal") _paypalForm(),

              const SizedBox(height: 30),

              _saveButton(context),
            ],
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
        const SizedBox(width: 12),
        Text("Add Payment Method", style: AppTextStyles.title(size: 20)),
      ],
    );
  }

  // =============================================================
  // PROVIDER SELECTOR (Visa / Mastercard / PayPal)
  // =============================================================
  Widget _providerSelector() {
    final types = ["Visa", "Mastercard", "PayPal"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Choose Provider", style: AppTextStyles.title(size: 16)),
        const SizedBox(height: 12),

        Row(
          children: types.map((t) {
            final active = t == selectedType;

            return GestureDetector(
              onTap: () => setState(() => selectedType = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: active ? AppColors.neonGradient : null,
                  color:
                  active ? null : AppColors.card.withOpacity(.22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : AppColors.border.withOpacity(.35),
                  ),
                ),
                child: PaymentProviderIcon(type: t),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isCard(String t) =>
      t.toLowerCase() == "visa" || t.toLowerCase() == "mastercard";

  // =============================================================
  // CARD FORM
  // =============================================================
  Widget _cardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField("Card Number", _cardNumberCtrl,
            hint: "1234 5678 9012 3456"),
        const SizedBox(height: 16),

        _inputField("Card Holder Name", _cardHolderCtrl,
            hint: "Full Name"),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _inputField("Expiry", _expiryCtrl, hint: "MM/YY"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _inputField("CVV", _cvvCtrl, hint: "123"),
            ),
          ],
        ),
      ],
    );
  }

  // =============================================================
  // PAYPAL FORM
  // =============================================================
  Widget _paypalForm() {
    return _inputField("PayPal Email", _paypalEmailCtrl,
        hint: "email@example.com");
  }

  // =============================================================
  // INPUT FIELD
  // =============================================================
  Widget _inputField(String label, TextEditingController ctrl,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(.22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(.35)),
          ),
          child: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
              TextStyle(color: Colors.white.withOpacity(.35), fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // SAVE BUTTON
  // =============================================================
  Widget _saveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, {
          "id": "pm_${DateTime.now().millisecondsSinceEpoch}",
          "type": selectedType,
          "last4": _isCard(selectedType)
              ? _cardNumberCtrl.text.isNotEmpty
              ? _cardNumberCtrl.text.substring(
              _cardNumberCtrl.text.length - 4)
              : "0000"
              : null,
          "email": selectedType.toLowerCase() == "paypal"
              ? _paypalEmailCtrl.text
              : null,
          "isDefault": false,
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.4),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Save Method",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
