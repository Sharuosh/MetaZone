// File: lib/screens/wallet/widgets/wallet_header.dart
// MetaZone Wallet — Header (Glass + Neon 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.card.withOpacity(.25),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            "Wallet",
            style: AppTextStyles.title(size: 22)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),

          // Transaction History Button
          _glassIconButton(
            icon: Icons.history,
            onTap: () {},
          ),
          const SizedBox(width: 10),

          // Settings Button
          _glassIconButton(
            icon: Icons.settings_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface.withOpacity(.25),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.15),
              blurRadius: 12,
              spreadRadius: 1,
            )
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
