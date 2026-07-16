// File: lib/screens/wallet/transactions/transactions_screen.dart
// MetaZone Wallet — Transactions Screen (Ultra PRO Neon UI)
// FINAL FIXED VERSION

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services & Models
import '../../../services/wallet/transactions_service.dart';
import '../../../models/wallet/transaction_model.dart';
import 'transaction_details_screen.dart';

// Widgets
import 'widgets/transaction_item.dart';
import 'widgets/transaction_filter_bar.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  int filterIndex = 0;
  final TransactionsService _tx = TransactionsService.instance;

  @override
  void initState() {
    super.initState();
    _tx.init();

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

  // =============================================================
  // FILTER LOGIC (ALIGNED WITH TransactionType)
  // =============================================================
  List<TransactionModel> _applyFilter(List<TransactionModel> list) {
    switch (filterIndex) {
      case 1: // Earnings
        return list.where((t) =>
        t.type == TransactionType.reward ||
            t.type == TransactionType.sell).toList();

      case 2: // Withdraw
        return list.where((t) =>
        t.type == TransactionType.withdraw).toList();

      case 3: // Add Funds
        return list.where((t) =>
        t.type == TransactionType.addFunds).toList();

      case 4: // Purchases
        return list.where((t) =>
        t.type == TransactionType.purchase ||
            t.type == TransactionType.fee).toList();

      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 20),

                TransactionFilterBar(
                  selectedIndex: filterIndex,
                  onSelect: (i) => setState(() => filterIndex = i),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<List<TransactionModel>>(
                    stream: _tx.transactionStream,
                    initialData: _tx.currentTransactions,
                    builder: (context, snapshot) {
                      final list = snapshot.data ?? [];
                      final filtered = _applyFilter(list);

                      if (filtered.isEmpty) return _emptyState();

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final t = filtered[i];

                          return TransactionItem(
                            id: t.id,
                            title: t.title,
                            subtitle:
                            "${t.date.day}/${t.date.month}/${t.date.year}",
                            amount:
                            "${t.isPositive ? '+' : '-'}${t.amount.toStringAsFixed(2)} ${t.currency}",
                            positive: t.isPositive,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailsScreen(
                                    transactionId: t.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
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
              color: AppColors.card.withOpacity(.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(.4)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text("Transactions", style: AppTextStyles.title(size: 22)),
        const Spacer(),
        Icon(Icons.receipt_long,
            size: 26, color: AppColors.primarySoft),
      ],
    );
  }

  // =============================================================
  // EMPTY STATE
  // =============================================================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              color: AppColors.textSoft.withOpacity(.4), size: 64),
          const SizedBox(height: 14),
          Text(
            "No transactions found",
            style: AppTextStyles.caption()
                .copyWith(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}
