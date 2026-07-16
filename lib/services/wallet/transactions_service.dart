// File: lib/services/wallet/transactions_service.dart
// MetaZone — Transactions Service (CLEAN & STABLE)
// Singleton + Stream based (UI ready)

import 'dart:async';
import '../../models/wallet/transaction_model.dart';

class TransactionsService {
  // ===============================
  // SINGLETON
  // ===============================
  TransactionsService._internal();
  static final TransactionsService instance =
  TransactionsService._internal();

  // ===============================
  // INTERNAL STORAGE
  // ===============================
  final List<TransactionModel> _transactions = [];

  final StreamController<List<TransactionModel>> _txStream =
  StreamController<List<TransactionModel>>.broadcast();

  // ===============================
  // PUBLIC STREAMS
  // ===============================
  Stream<List<TransactionModel>> get transactionStream =>
      _txStream.stream;

  List<TransactionModel> get currentTransactions =>
      List.unmodifiable(_transactions);

  // ===============================
  // INIT (call once)
  // ===============================
  void init() {
    _txStream.add(currentTransactions);
  }

  // ===============================
  // ADD TRANSACTION
  // ===============================
  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String title,
    String? description,
  }) async {
    final tx = TransactionModel(
      id: "tx_${DateTime.now().millisecondsSinceEpoch}",
      type: type,
      amount: amount,
      currency: "MC",
      date: DateTime.now(),
      title: title,
      description: description,
      isPositive: amount >= 0,
    );

    _transactions.insert(0, tx);
    _txStream.add(currentTransactions);
  }

  // ===============================
  // GET BY ID
  // ===============================
  Future<TransactionModel?> getById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ===============================
  // CLEAR (DEBUG)
  // ===============================
  void clear() {
    _transactions.clear();
    _txStream.add(currentTransactions);
  }

  // ===============================
  // DISPOSE
  // ===============================
  void dispose() {
    _txStream.close();
  }
}
