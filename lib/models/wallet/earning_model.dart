// File: lib/models/wallet/earning_model.dart
// MetaZone Wallet — Earning Model (Creator Income + AR Rewards)

import 'package:flutter/material.dart';

enum EarningType {
  spotVisit,
  portalVisit,
  portalCreation,
  assetSold,
  dailyReward,
  bonus,
  referral,
}

class EarningModel {
  final String id;
  final EarningType type;
  final double amount;
  final String currency; // "MC"
  final DateTime date;
  final String title;
  final String? source; // e.g. Spot name or user
  final String? note;   // Optional description

  EarningModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.title,
    this.source,
    this.note,
  });

  // ---------------------------------------------------
  // Convert to Map
  // ---------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type.name,
      "amount": amount,
      "currency": currency,
      "date": date.toIso8601String(),
      "title": title,
      "source": source,
      "note": note,
    };
  }

  // ---------------------------------------------------
  // Read from Map (JSON)
  // ---------------------------------------------------
  factory EarningModel.fromMap(Map<String, dynamic> map) {
    return EarningModel(
      id: map["id"] ?? "",
      type: EarningType.values.firstWhere(
            (e) => e.name == map["type"],
        orElse: () => EarningType.bonus,
      ),
      amount: (map["amount"] as num).toDouble(),
      currency: map["currency"] ?? "MC",
      date: DateTime.parse(map["date"]),
      title: map["title"] ?? "Earning",
      source: map["source"],
      note: map["note"],
    );
  }

  factory EarningModel.fromJson(Map<String, dynamic> json) =>
      EarningModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  // ---------------------------------------------------
  // COPYWITH (Modify specific fields easily)
  // ---------------------------------------------------
  EarningModel copyWith({
    String? id,
    EarningType? type,
    double? amount,
    String? currency,
    DateTime? date,
    String? title,
    String? source,
    String? note,
  }) {
    return EarningModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      title: title ?? this.title,
      source: source ?? this.source,
      note: note ?? this.note,
    );
  }
}
