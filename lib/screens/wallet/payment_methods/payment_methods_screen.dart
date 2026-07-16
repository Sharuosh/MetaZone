// File: lib/screens/wallet/payment_methods/payment_methods_screen.dart
// MetaZone Wallet — Payment Methods Screen (CLEAN & LIVE)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Services & Models
import '../../../services/wallet/payment_service.dart';
import '../../../models/wallet/payment_method_model.dart';

// Screens
import 'add_payment_method_screen.dart';

// Widgets
import 'widgets/payment_method_card.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  final PaymentService _payment = PaymentService.instance;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();

    _payment.init(); // 🔥 مهم
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // =============================================================
  // ACTIONS
  // =============================================================

  Future<void> _setDefault(PaymentMethodModel model) async {
    final methods = await _payment.getPaymentMethods();

    for (final m in methods) {
      await _payment.updateMethod(
        m.copyWith(isDefault: m.id == model.id),
      );
    }
  }

  Future<void> _delete(String id) async {
    await _payment.removePaymentMethod(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<List<PaymentMethodModel>>(
                    stream: _payment.methodsStream,
                    initialData: _payment.currentMethods,
                    builder: (context, snapshot) {
                      final methods = snapshot.data ?? [];

                      if (methods.isEmpty) {
                        return _empty();
                      }

                      return ListView.separated(
                        itemCount: methods.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final m = methods[i];
                          return PaymentMethodCard(
                            id: m.id,
                            type: m.providerName,
                            last4: m.maskedNumber,
                            email: m.type ==
                                PaymentMethodType.paypal
                                ? m.providerName
                                : null,
                            isDefault: m.isDefault,
                            onSetDefault: () => _setDefault(m),
                            onDelete: () => _delete(m.id),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                _addButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // UI
  // =============================================================

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.25),
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: AppColors.border.withOpacity(.4)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Text("Payment Methods",
            style: AppTextStyles.title(size: 22)),
        const Spacer(),
        Icon(Icons.credit_card,
            size: 26, color: AppColors.primarySoft),
      ],
    );
  }

  Widget _addButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final PaymentMethodModel? result =
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddPaymentMethodScreen(),
          ),
        );

        if (result != null) {
          await _payment.addPaymentMethod(result);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.4),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Add Payment Method",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Text(
        "No payment methods added yet",
        style: AppTextStyles.caption(),
      ),
    );
  }
}
