// File: lib/models/wallet/transaction_model.dart
// MetaZone Wallet — Transaction Model (Enterprise Ready)

import 'package:flutter/material.dart';

enum TransactionType {
  addFunds,
  withdraw,
  purchase,
  sell,
  reward,
  fee,
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String currency; // "MC" or real currency later
  final DateTime date;
  final String title;
  final String? description;
  final bool isPositive;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.title,
    this.description,
    required this.isPositive,
  });

  // -------------------------------
  // JSON / Map Parsing
  // -------------------------------

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type.name,
      "amount": amount,
      "currency": currency,
      "date": date.toIso8601String(),
      "title": title,
      "description": description,
      "isPositive": isPositive,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map["id"],
      type: TransactionType.values.firstWhere(
            (e) => e.name == map["type"],
        orElse: () => TransactionType.purchase,
      ),
      amount: (map["amount"] as num).toDouble(),
      currency: map["currency"] ?? "MC",
      date: DateTime.parse(map["date"]),
      title: map["title"],
      description: map["description"],
      isPositive: map["isPositive"] ?? false,
    );
  }

  // -------------------------------
  // JSON Support
  // -------------------------------
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  // -------------------------------
  // CopyWith (Modify fields easily)
  // -------------------------------
  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? currency,
    DateTime? date,
    String? title,
    String? description,
    bool? isPositive,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      isPositive: isPositive ?? this.isPositive,
    );
  }
}
