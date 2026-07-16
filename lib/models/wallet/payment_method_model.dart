// File: lib/models/wallet/payment_method_model.dart
// MetaZone Wallet — Payment Method Model (2025 Edition)

enum PaymentMethodType {
  card,        // Visa / MasterCard
  paypal,      // PayPal
  wallet,      // Mobile Wallet (Vodafone Cash, etc.)
  bank,        // Bank Account
  crypto,      // Crypto Wallet (optional future)
}

class PaymentMethodModel {
  final String id;                   // unique id
  final PaymentMethodType type;      // نوع الوسيلة
  final String providerName;         // Visa / PayPal / Vodafone / Binance
  final String maskedNumber;         // **** 5478
  final bool isDefault;              // هل هي الوسيلة الافتراضية؟
  final String? icon;                // asset path (optional)
  final DateTime addedAt;            // امتى المستخدم أضافها

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.providerName,
    required this.maskedNumber,
    required this.isDefault,
    this.icon,
    required this.addedAt,
  });

  // ------------------------------------------------------------
  // Convert to JSON Map (for Firebase / Backend)
  // ------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type.name,
      "providerName": providerName,
      "maskedNumber": maskedNumber,
      "isDefault": isDefault,
      "icon": icon,
      "addedAt": addedAt.toIso8601String(),
    };
  }

  // ------------------------------------------------------------
  // Read from JSON Map
  // ------------------------------------------------------------
  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map["id"],
      type: PaymentMethodType.values.firstWhere(
            (e) => e.name == map["type"],
        orElse: () => PaymentMethodType.card,
      ),
      providerName: map["providerName"] ?? "",
      maskedNumber: map["maskedNumber"] ?? "",
      isDefault: map["isDefault"] ?? false,
      icon: map["icon"],
      addedAt: DateTime.parse(map["addedAt"]),
    );
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  // ------------------------------------------------------------
  // CopyWith
  // ------------------------------------------------------------
  PaymentMethodModel copyWith({
    String? id,
    PaymentMethodType? type,
    String? providerName,
    String? maskedNumber,
    bool? isDefault,
    String? icon,
    DateTime? addedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      providerName: providerName ?? this.providerName,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      isDefault: isDefault ?? this.isDefault,
      icon: icon ?? this.icon,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
