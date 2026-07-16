// File: lib/screens/wallet/transactions/transaction_details_screen.dart
// MetaZone Wallet — Transaction Details (Neon Glass UI)
// CLEAN + COMPATIBLE VERSION

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services & Models
import '../../../services/wallet/transactions_service.dart';
import '../../../models/wallet/transaction_model.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
  });

  IconData _icon(TransactionModel tx) {
    switch (tx.type) {
      case TransactionType.addFunds:
        return Icons.arrow_downward_rounded;
      case TransactionType.withdraw:
        return Icons.arrow_upward_rounded;
      case TransactionType.reward:
        return Icons.card_giftcard_rounded;
      case TransactionType.sell:
        return Icons.trending_up_rounded;
      case TransactionType.purchase:
      case TransactionType.fee:
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  Color _amountColor(TransactionModel tx) =>
      tx.amount >= 0 ? Colors.greenAccent : Colors.redAccent;

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.addFunds:
        return "Add Funds";
      case TransactionType.withdraw:
        return "Withdraw";
      case TransactionType.purchase:
        return "Purchase";
      case TransactionType.sell:
        return "Sale";
      case TransactionType.reward:
        return "Reward";
      case TransactionType.fee:
        return "Fee";
    }
  }

  @override
  Widget build(BuildContext context) {
    final TransactionsService txService = TransactionsService.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<TransactionModel?>(
          future: txService.getById(transactionId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final tx = snapshot.data!;
            final amountText =
                "${tx.amount >= 0 ? '+' : ''}${tx.amount.toStringAsFixed(2)} ${tx.currency}";

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 26),

                  _headerCard(tx, amountText),
                  const SizedBox(height: 26),

                  Text("Transaction Info",
                      style: AppTextStyles.title(size: 16)),
                  const SizedBox(height: 12),

                  _infoRow("Transaction ID", tx.id),
                  _infoRow("Type", _typeLabel(tx.type)),
                  _infoRow(
                    "Date",
                    "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                  ),
                  _infoRow(
                    "Amount",
                    amountText,
                    highlight: true,
                    color: _amountColor(tx),
                  ),

                  const Spacer(),

                  _bottomActions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =============================================================
  // TOP BAR
  // =============================================================
  Widget _topBar(BuildContext context) {
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
        Text(
          "Transaction Details",
          style: AppTextStyles.title(size: 20),
        ),
      ],
    );
  }

  // =============================================================
  // HEADER CARD
  // =============================================================
  Widget _headerCard(TransactionModel tx, String amountText) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(_icon(tx), size: 36, color: Colors.black),
          ),
          const SizedBox(height: 18),
          Text(
            amountText,
            style: AppTextStyles.heading(size: 26)
                .copyWith(color: _amountColor(tx)),
          ),
          const SizedBox(height: 6),
          Text(
            tx.title,
            style: AppTextStyles.caption(size: 14),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // INFO ROW
  // =============================================================
  Widget _infoRow(
      String label,
      String value, {
        bool highlight = false,
        Color? color,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.caption()),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.caption(size: 14).copyWith(
              color: highlight ? color : AppColors.text,
              fontWeight:
              highlight ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ACTIONS
  // =============================================================
  Widget _bottomActions() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // TODO: PDF receipt later
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.5),
                  blurRadius: 16,
                )
              ],
            ),
            child: const Center(
              child: Text(
                "Download Receipt",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Report an issue",
          style: AppTextStyles.caption().copyWith(
            color: Colors.redAccent,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
