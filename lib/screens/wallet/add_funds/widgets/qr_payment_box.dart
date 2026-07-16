// File: lib/screens/wallet/add_funds/widgets/qr_payment_box.dart
// MetaZone Wallet — QR Payment Box (Neon PRO 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class QRPaymentBox extends StatelessWidget {
  final String providerName;
  final String qrData; // This would be used to generate the QR later
  final VoidCallback onConfirm;

  const QRPaymentBox({
    super.key,
    required this.providerName,
    required this.qrData,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.25),
            blurRadius: 14,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$providerName QR Code",
            style: AppTextStyles.title(size: 16),
          ),
          const SizedBox(height: 14),

          // Fake QR (Replace with QR Generator later)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage("assets/images/qr_placeholder.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "Scan this code using your ${providerName} app to complete the payment.",
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(size: 12)
                .copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.4),
                    blurRadius: 16,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  "I Have Paid",
                  style: AppTextStyles.title(size: 14)
                      .copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
