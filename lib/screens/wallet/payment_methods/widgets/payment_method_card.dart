// File: lib/screens/wallet/payment_methods/widgets/payment_method_card.dart
// MetaZone Wallet — Payment Method Card (Neon Glass PRO UI)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'payment_provider_icon.dart';

class PaymentMethodCard extends StatelessWidget {
  final String id;
  final String type;     // Visa / Mastercard / PayPal / ApplePay...
  final String? last4;   // only for cards
  final String? email;   // only for PayPal
  final bool isDefault;

  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const PaymentMethodCard({
    super.key,
    required this.id,
    required this.type,
    this.last4,
    this.email,
    required this.isDefault,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDefault
              ? AppColors.primary
              : AppColors.border.withOpacity(.35),
        ),
        boxShadow: isDefault
            ? [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.6),
            blurRadius: 18,
            spreadRadius: 1,
          )
        ]
            : [],
      ),
      child: Row(
        children: [
          // Provider Icon
          PaymentProviderIcon(type: type),

          const SizedBox(width: 16),

          // Card text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: AppTextStyles.title(size: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  email != null
                      ? email!
                      : "•••• ${last4 ?? "----"}",
                  style: AppTextStyles.caption(size: 12),
                ),
                const SizedBox(height: 6),

                if (isDefault)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.neonGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "DEFAULT",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Right side buttons
          Column(
            children: [
              // Set Default
              if (!isDefault)
                GestureDetector(
                  onTap: onSetDefault,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withOpacity(.3),
                      ),
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 20),
                  ),
                ),

              if (!isDefault) const SizedBox(height: 10),

              // Delete
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(.4),
                    ),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
