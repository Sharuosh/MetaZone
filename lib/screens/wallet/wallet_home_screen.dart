// File: lib/screens/wallet/wallet_home_screen.dart
// MetaZone — Wallet Home (Ultra PRO UI 2025)
// Full Neon Glass Wallet Dashboard (FULLY WIRED – 6 ACTIONS ✅)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Widgets
import 'widgets/wallet_header.dart';
import 'widgets/wallet_balance_card.dart';
import 'widgets/earnings_strip.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recent_transaction_item.dart';
import 'widgets/rewards_preview.dart';

// Screens
import 'add_funds/add_funds_screen.dart';
import 'withdraw/withdraw_screen.dart';
import 'transactions/transactions_screen.dart';
import 'earnings/earnings_screen_v2.dart';
import 'rewards/rewards_screen.dart';
import 'payment_methods/payment_methods_screen.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

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
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _go(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Stack(
            children: [
              Positioned.fill(child: _background()),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WalletHeader(),
                    const SizedBox(height: 20),

                    WalletBalanceCard(
                      onAddFunds: () => _go(const AddFundsScreen()),
                      onWithdraw: () => _go(const WithdrawScreen()),
                    ),
                    const SizedBox(height: 18),

                    EarningsStrip(
                      onTap: () => _go(const EarningsScreenV2()),
                    ),
                    const SizedBox(height: 18),

                    /// ✅ QUICK ACTIONS — 6 ICONS WIRED
                    QuickActionsGrid(
                      onAddFunds: () => _go(const AddFundsScreen()),
                      onWithdraw: () => _go(const WithdrawScreen()),
                      onTransactions: () =>
                          _go(const TransactionsScreen()),
                      onEarnings: () =>
                          _go(const EarningsScreenV2()),
                      onRewards: () =>
                          _go(const RewardsScreen()),
                      onPaymentMethods: () =>
                          _go(const PaymentMethodsScreen()),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      "Recent Activity",
                      style: AppTextStyles.title(size: 16),
                    ),
                    const SizedBox(height: 14),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: const [
                          RecentTransactionItem(
                            icon: Icons.add_circle,
                            title: "Added Funds",
                            date: "Today, 3:45 PM",
                            amount: "+ 50.00 MC",
                            positive: true,
                          ),
                          RecentTransactionItem(
                            icon: Icons.shopping_bag,
                            title: "Bought AR Portal",
                            date: "Yesterday",
                            amount: "- 12.00 MC",
                            positive: false,
                          ),
                          RecentTransactionItem(
                            icon: Icons.card_giftcard,
                            title: "Daily Reward",
                            date: "Yesterday",
                            amount: "+ 2.00 MC",
                            positive: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    RewardsPreview(
                      onTap: () => _go(const RewardsScreen()),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _background() {
    return CustomPaint(
      painter: _NeonBG(),
      child: Container(),
    );
  }
}

class _NeonBG extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < 12; i++) {
      final y = size.height * (.06 * i + .04);
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(
          size.width * .25,
          y + 14 * (i.isEven ? 1 : -1),
          size.width * .5,
          y - 10 * (i.isOdd ? 1 : -1),
        )
        ..quadraticBezierTo(
          size.width * .75,
          y + 12 * (i.isEven ? -1 : 1),
          size.width,
          y,
        );

      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
