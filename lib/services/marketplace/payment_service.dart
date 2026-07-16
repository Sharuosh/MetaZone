// lib/services/payment_service.dart
import '../../models/order_model.dart';
import '../../services/marketplace/market_api.dart';
import '../../models/market_item.dart';

class PaymentService {
  // -------------------------------------------------------
  // محاكاة الدفع (للتجربة)
  // -------------------------------------------------------
  static Future<bool> simulatePayment(double amount) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  // -------------------------------------------------------
  // معالجة الدفع – يبدأ ثم ينشئ Order
  // -------------------------------------------------------
  static Future<OrderModel> processPayment({
    required String userId,
    required MarketItem item,
    required String method, // stripe / wallet / etc
  }) async {
    final ok = await simulatePayment(item.price);
    if (!ok) throw Exception("Payment failed");

    // تسجيل الطلب في السيرفر
    return await MarketAPI.createOrder(
      userId: userId,
      item: item,
      paymentMethod: method,
    );
  }
}
