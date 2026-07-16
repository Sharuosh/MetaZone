import 'dart:async';
import '../../models/wallet/payment_method_model.dart';

class PaymentService {
  // ================= SINGLETON =================
  static final PaymentService instance = PaymentService._internal();
  PaymentService._internal();

  // ================= DATA =================
  final List<PaymentMethodModel> _methods = [];

  final StreamController<List<PaymentMethodModel>> _stream =
  StreamController.broadcast();

  Stream<List<PaymentMethodModel>> get methodsStream => _stream.stream;
  List<PaymentMethodModel> get currentMethods => List.unmodifiable(_methods);

  // ================= INIT =================
  void init() {
    if (_methods.isNotEmpty) return;

    _methods.add(
      PaymentMethodModel(
        id: "pm_default",
        type: PaymentMethodType.card,
        providerName: "Visa",
        maskedNumber: "**** 2211",
        isDefault: true,
        addedAt: DateTime.now(),
      ),
    );

    _stream.add(_methods);
  }

  // ================= GET =================
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return currentMethods;
  }

  PaymentMethodModel? get defaultMethod {
    try {
      return _methods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return null;
    }
  }

  // ================= ADD =================
  Future<void> addPaymentMethod(PaymentMethodModel model) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_methods.isEmpty) {
      model = model.copyWith(isDefault: true);
    }

    _methods.add(model);
    _stream.add(_methods);
  }

  // ================= UPDATE =================
  Future<void> updateMethod(PaymentMethodModel model) async {
    final index = _methods.indexWhere((m) => m.id == model.id);
    if (index == -1) return;

    _methods[index] = model;
    _stream.add(_methods);
  }

  // ================= REMOVE =================
  Future<void> removePaymentMethod(String id) async {
    _methods.removeWhere((m) => m.id == id);

    if (_methods.every((m) => !m.isDefault) && _methods.isNotEmpty) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
    }

    _stream.add(_methods);
  }

  // ================= PAYMENT =================
  Future<bool> processPayment({
    required double amount,
    required PaymentMethodModel method,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return amount > 0;
  }

  void dispose() {
    _stream.close();
  }
}
