// File: lib/screens/wallet/earnings/earnings_screen_v2.dart
// MetaZone — Earnings Screen V2 (LIVE + REAL DATA)

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services & Models
import '../../../services/wallet/transactions_service.dart';
import '../../../models/wallet/transaction_model.dart';

// Widgets
import 'widgets/month_filter_tab.dart';

class EarningsScreenV2 extends StatefulWidget {
  const EarningsScreenV2({super.key});

  @override
  State<EarningsScreenV2> createState() => _EarningsScreenV2State();
}

class _EarningsScreenV2State extends State<EarningsScreenV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  final TransactionsService _tx = TransactionsService.instance;

  int _selectedMonth = 0;
  bool _showInsights = true;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();

    _tx.init();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // =============================================================
  // BUSINESS LOGIC
  // =============================================================

  List<TransactionModel> _earningsOnly(List<TransactionModel> all) {
    return all
        .where((t) =>
    t.type == TransactionType.reward ||
        t.type == TransactionType.sell)
        .toList();
  }

  List<TransactionModel> _filterByMonth(List<TransactionModel> list) {
    if (_selectedMonth == 0) return list;

    final now = DateTime.now();
    final targetMonth = now.month - (_selectedMonth - 1);

    return list.where((t) =>
    t.date.month == targetMonth &&
        t.date.year == now.year).toList();
  }

  double _total(List<TransactionModel> list) =>
      list.fold(0, (s, t) => s + t.amount);

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
                _buildTopBar(),
                const SizedBox(height: 16),

                StreamBuilder<List<TransactionModel>>(
                  stream: _tx.transactionStream,
                  initialData: _tx.currentTransactions,
                  builder: (context, snapshot) {
                    final allEarnings =
                    _earningsOnly(snapshot.data ?? []);

                    final filtered =
                    _filterByMonth(allEarnings)..sort(
                          (a, b) => b.date.compareTo(a.date),
                    );

                    final total = _total(allEarnings);
                    final thisMonth = _total(
                      allEarnings.where((t) {
                        final now = DateTime.now();
                        return t.date.month == now.month &&
                            t.date.year == now.year;
                      }).toList(),
                    );

                    final avg = filtered.isEmpty
                        ? 0
                        : filtered.fold<double>(
                        0, (s, t) => s + t.amount) /
                        filtered.length;

                    return Expanded(
                      child: Column(
                        children: [
                          _buildBalance(
                            total: total,
                            thisMonth: thisMonth,
                          ),
                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildInsights(
                                  avg: avg.toDouble(),
                                  count: filtered.length,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 160,
                                child: MonthFilterTab(
                                  selectedIndex: _selectedMonth,
                                  onSelect: (i) =>
                                      setState(() => _selectedMonth = i),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          _sectionHeader("Earnings History"),
                          const SizedBox(height: 10),

                          Expanded(
                            child: filtered.isEmpty
                                ? _empty()
                                : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final e = filtered[i];
                                return _earningRow(
                                  title: e.title,
                                  subtitle:
                                  e.type.name.toUpperCase(),
                                  date:
                                  "${e.date.day}/${e.date.month}/${e.date.year}",
                                  amount:
                                  "+${e.amount.toStringAsFixed(2)} ${e.currency}",
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // UI
  // =============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withOpacity(.3),
              ),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text("Earnings", style: AppTextStyles.title(size: 20)),
      ],
    );
  }

  Widget _buildBalance({
    required double total,
    required double thisMonth,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.card.withOpacity(.18),
        border: Border.all(color: AppColors.border.withOpacity(.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Earnings",
              style: AppTextStyles.caption(size: 12)),
          const SizedBox(height: 6),
          Text("${total.toStringAsFixed(2)} MC",
              style: AppTextStyles.title(size: 26)),
          const SizedBox(height: 6),
          Text("This Month: +${thisMonth.toStringAsFixed(2)} MC",
              style: AppTextStyles.caption()),
        ],
      ),
    );
  }

  Widget _buildInsights({
    required double avg,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card.withOpacity(.14),
        border: Border.all(color: AppColors.border.withOpacity(.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Insights", style: AppTextStyles.caption()),
          const SizedBox(height: 8),
          if (_showInsights) ...[
            Text("Avg / transaction: ${avg.toStringAsFixed(2)} MC",
                style: AppTextStyles.caption()),
            const SizedBox(height: 6),
            Text("Transactions: $count",
                style: AppTextStyles.caption()),
          ] else
            Text("Hidden", style: AppTextStyles.caption()),
        ],
      ),
    );
  }

  Widget _earningRow({
    required String title,
    required String subtitle,
    required String date,
    required String amount,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.title(size: 14)),
                Text("$subtitle • $date",
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
          Text(amount,
              style: AppTextStyles.title(size: 14)
                  .copyWith(color: Colors.greenAccent)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.title(size: 16)),
      ],
    );
  }

  Widget _empty() {
    return Center(
      child:
      Text("No earnings yet", style: AppTextStyles.caption()),
    );
  }
}
