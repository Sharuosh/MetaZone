import 'package:flutter/material.dart';

enum CreateTypeVariant {
  object,
  scene,
  portal,
  ai,
}

enum CreateTypeDifficulty {
  beginner,
  intermediate,
  advanced,
}

class CreateType {
  const CreateType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,

    this.description = '',

    this.thumbnail,

    this.category = 'General',

    this.variant = CreateTypeVariant.object,

    this.difficulty = CreateTypeDifficulty.beginner,

    this.accentColor = const Color(0xff5B8CFF),

    this.badge,

    this.featureCount,

    this.order = 0,

    this.estimatedMinutes = 5,

    this.usageCount = 0,

    this.recommended = false,

    this.locked = false,

    this.isNew = false,

    this.isPremium = false,

    this.isFavorite = false,

    this.enabled = true,
  });

  final String id;

  final String title;

  final String subtitle;

  final String description;

  final IconData icon;

  final String? thumbnail;

  final String category;

  final CreateTypeVariant variant;

  final CreateTypeDifficulty difficulty;

  final Color accentColor;

  final String? badge;

  final String? featureCount;

  final int order;

  final int estimatedMinutes;

  final int usageCount;

  final bool recommended;

  final bool locked;

  final bool isNew;

  final bool isPremium;

  final bool isFavorite;

  final bool enabled;

  bool get isAI => variant == CreateTypeVariant.ai;

  bool get isPortal => variant == CreateTypeVariant.portal;

  bool get isScene => variant == CreateTypeVariant.scene;

  bool get isObject => variant == CreateTypeVariant.object;

  bool get isAvailable => enabled && !locked;

  static const empty = CreateType(
    id: '',
    title: '',
    subtitle: '',
    icon: Icons.category,
  );

  CreateType copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    IconData? icon,
    String? thumbnail,
    String? category,
    CreateTypeVariant? variant,
    CreateTypeDifficulty? difficulty,
    Color? accentColor,
    String? badge,
    String? featureCount,
    int? order,
    int? estimatedMinutes,
    int? usageCount,
    bool? recommended,
    bool? locked,
    bool? isNew,
    bool? isPremium,
    bool? isFavorite,
    bool? enabled,
  }) {
    return CreateType(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      variant: variant ?? this.variant,
      difficulty: difficulty ?? this.difficulty,
      accentColor: accentColor ?? this.accentColor,
      badge: badge ?? this.badge,
      featureCount: featureCount ?? this.featureCount,
      order: order ?? this.order,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      usageCount: usageCount ?? this.usageCount,
      recommended: recommended ?? this.recommended,
      locked: locked ?? this.locked,
      isNew: isNew ?? this.isNew,
      isPremium: isPremium ?? this.isPremium,
      isFavorite: isFavorite ?? this.isFavorite,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'thumbnail': thumbnail,
      'category': category,
      'variant': variant.name,
      'difficulty': difficulty.name,
      'badge': badge,
      'featureCount': featureCount,
      'order': order,
      'estimatedMinutes': estimatedMinutes,
      'usageCount': usageCount,
      'recommended': recommended,
      'locked': locked,
      'isNew': isNew,
      'isPremium': isPremium,
      'isFavorite': isFavorite,
      'enabled': enabled,
    };
  }

  factory CreateType.fromJson(Map<String, dynamic> json) {
    return CreateType(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'],
      category: json['category'] ?? 'General',
      icon: Icons.category,
      variant: CreateTypeVariant.values.firstWhere(
            (e) => e.name == json['variant'],
        orElse: () => CreateTypeVariant.object,
      ),
      difficulty: CreateTypeDifficulty.values.firstWhere(
            (e) => e.name == json['difficulty'],
        orElse: () => CreateTypeDifficulty.beginner,
      ),
      badge: json['badge'],
      featureCount: json['featureCount'],
      order: json['order'] ?? 0,
      estimatedMinutes: json['estimatedMinutes'] ?? 5,
      usageCount: json['usageCount'] ?? 0,
      recommended: json['recommended'] ?? false,
      locked: json['locked'] ?? false,
      isNew: json['isNew'] ?? false,
      isPremium: json['isPremium'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      enabled: json['enabled'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CreateType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}