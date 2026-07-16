// File: lib/services/wallet/wallet_service.dart
// MetaZone – Wallet Service (Mock Live Version)
// SINGLETON + STREAM BASED
// Backend-ready (Firebase / API later)

import 'dart:async';

class WalletService {
  // --------------------------------------------------------
  // SINGLETON
  // --------------------------------------------------------
  WalletService._internal();
  static final WalletService instance = WalletService._internal();

  // --------------------------------------------------------
  // WALLET STATE (Mock Data)
  // --------------------------------------------------------
  double _balance = 125.50; // MC
  double _lifetimeEarnings = 982.40;
  double _lifetimeSpent = 312.00;

  // --------------------------------------------------------
  // STREAM CONTROLLERS
  // --------------------------------------------------------
  final StreamController<double> _balanceStream =
  StreamController<double>.broadcast();

  Stream<double> get balanceStream => _balanceStream.stream;

  double get currentBalance => _balance;

  // --------------------------------------------------------
  // INIT (Call once if needed)
  // --------------------------------------------------------
  void init() {
    _balanceStream.add(_balance);
  }

  // --------------------------------------------------------
  // GET BALANCE
  // --------------------------------------------------------
  Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _balance;
  }

  // --------------------------------------------------------
  // ADD FUNDS
  // --------------------------------------------------------
  Future<bool> addFunds(double amount) async {
    if (amount <= 0) return false;

    await Future.delayed(const Duration(milliseconds: 500));

    _balance += amount;
    _lifetimeEarnings += amount;

    _balanceStream.add(_balance);
    return true;
  }

  // --------------------------------------------------------
  // WITHDRAW
  // --------------------------------------------------------
  Future<bool> withdraw(double amount) async {
    if (amount <= 0 || amount > _balance) return false;

    await Future.delayed(const Duration(milliseconds: 500));

    _balance -= amount;
    _lifetimeSpent += amount;

    _balanceStream.add(_balance);
    return true;
  }

  // --------------------------------------------------------
  // WALLET OVERVIEW
  // --------------------------------------------------------
  Future<Map<String, dynamic>> getWalletOverview() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      "balance": _balance,
      "lifetimeEarnings": _lifetimeEarnings,
      "lifetimeSpent": _lifetimeSpent,
      "weeklyGrowth": 12.4,
      "transactionsCount": 42,
    };
  }

  // --------------------------------------------------------
  // RESET (DEBUG / LOGOUT)
  // --------------------------------------------------------
  void reset() {
    _balance = 0;
    _lifetimeEarnings = 0;
    _lifetimeSpent = 0;
    _balanceStream.add(_balance);
  }

  // --------------------------------------------------------
  // DISPOSE (rarely used in singleton)
  // --------------------------------------------------------
  void dispose() {
    _balanceStream.close();
  }
}
