// lib/models/order_model.dart
import 'license_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String itemId;
  final double price;
  final String status;           // pending / paid / refunded
  final String paymentMethod;    // Stripe / Wallet / PayPal
  final DateTime timestamp;

  final List<String> downloadLinks;  // الروابط بعد الدفع
  final LicenseModel license;        // نسخة الترخيص وقت الشراء

  final String deviceInfo;           // حماية ضد القرصنة

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.itemId,
    required this.price,
    required this.status,
    required this.paymentMethod,
    required this.timestamp,
    required this.downloadLinks,
    required this.license,
    required this.deviceInfo,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      userId: json['userId'],
      itemId: json['itemId'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      timestamp: DateTime.parse(json['timestamp']),
      downloadLinks: List<String>.from(json['downloadLinks']),
      license: LicenseModel.fromJson(json['license']),
      deviceInfo: json['deviceInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'itemId': itemId,
      'price': price,
      'status': status,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
      'downloadLinks': downloadLinks,
      'license': license.toJson(),
      'deviceInfo': deviceInfo,
    };
  }
}
