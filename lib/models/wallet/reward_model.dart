// File: lib/models/wallet/reward_model.dart
// MetaZone Wallet — Reward Model (Daily, Achievements, Streaks)

import 'package:flutter/material.dart';

/// أنواع المكافآت داخل MetaZone
enum RewardType {
  daily,
  achievement,
  streak,
  mission,
  bonus,
}

/// حالة المكافأة
enum RewardStatus {
  locked,
  inProgress,
  unlocked,
  claimed,
}

class RewardModel {
  final String id;
  final RewardType type;
  final String title;
  final String description;
  final String icon; // could be asset path or icon reference
  final RewardStatus status;
  final double progress; // 0 → 1
  final double rewardAmount; // MC Coins
  final DateTime? availableAt; // for streak/daily cooldown

  RewardModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    required this.progress,
    required this.rewardAmount,
    this.availableAt,
  });

  // ------------------------------------------
  // Convert to Map (for API / Firebase)
  // ------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type.name,
      "title": title,
      "description": description,
      "icon": icon,
      "status": status.name,
      "progress": progress,
      "rewardAmount": rewardAmount,
      "availableAt": availableAt?.toIso8601String(),
    };
  }

  // ------------------------------------------
  // Read from Map (JSON)
  // ------------------------------------------
  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      id: map["id"],
      type: RewardType.values.firstWhere(
            (e) => e.name == map["type"],
        orElse: () => RewardType.daily,
      ),
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      icon: map["icon"] ?? "assets/icons/reward.png",
      status: RewardStatus.values.firstWhere(
            (e) => e.name == map["status"],
        orElse: () => RewardStatus.locked,
      ),
      progress: (map["progress"] as num?)?.toDouble() ?? 0.0,
      rewardAmount: (map["rewardAmount"] as num?)?.toDouble() ?? 0.0,
      availableAt: map["availableAt"] != null
          ? DateTime.parse(map["availableAt"])
          : null,
    );
  }

  factory RewardModel.fromJson(Map<String, dynamic> json) =>
      RewardModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  // ------------------------------------------
  // CopyWith (Edit fields)
  // ------------------------------------------
  RewardModel copyWith({
    String? id,
    RewardType? type,
    String? title,
    String? description,
    String? icon,
    RewardStatus? status,
    double? progress,
    double? rewardAmount,
    DateTime? availableAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      availableAt: availableAt ?? this.availableAt,
    );
  }
}
