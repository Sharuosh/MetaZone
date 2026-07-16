// File: lib/screens/wallet/widgets/wallet_balance_card.dart
// MetaZone Wallet — Balance Card (Neon Glow + Glassmorphism 2025)
// LIVE BALANCE VERSION

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../services/wallet/wallet_service.dart';

class WalletBalanceCard extends StatefulWidget {
  final VoidCallback? onAddFunds;
  final VoidCallback? onWithdraw;

  const WalletBalanceCard({
    super.key,
    this.onAddFunds,
    this.onWithdraw,
  });

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowScale;

  final WalletService _wallet = WalletService.instance;

  @override
  void initState() {
    super.initState();

    _wallet.init();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowScale = Tween<double>(begin: .98, end: 1.03).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _glowScale,
      child: StreamBuilder<double>(
        stream: _wallet.balanceStream,
        initialData: _wallet.currentBalance,
        builder: (context, snapshot) {
          final balance = snapshot.data ?? 0.0;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppColors.surface.withOpacity(.65),
                  AppColors.card.withOpacity(.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.border.withOpacity(.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Label
                Text(
                  "Meta Credits Balance",
                  style: AppTextStyles.caption(size: 12)
                      .copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),

                // Balance Value (LIVE)
                Text(
                  "${balance.toStringAsFixed(2)} MC",
                  style: AppTextStyles.title(size: 30)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                // Rewards Info (Static for now)
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 20, color: AppColors.primarySoft),
                    const SizedBox(width: 6),
                    Text(
                      "+ Rewards Active",
                      style: AppTextStyles.caption()
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        label: "Add Funds",
                        icon: Icons.add_circle,
                        onTap: widget.onAddFunds,
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _actionBtn(
                        label: "Withdraw",
                        icon: Icons.arrow_circle_down_rounded,
                        onTap: widget.onWithdraw,
                        isPrimary: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isPrimary ? AppColors.neonGradient : null,
          color: !isPrimary ? AppColors.surface.withOpacity(.22) : null,
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : AppColors.border.withOpacity(.45),
          ),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.5),
              blurRadius: 18,
              spreadRadius: 1,
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isPrimary ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body(size: 14).copyWith(
                color: isPrimary ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
