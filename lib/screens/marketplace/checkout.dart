import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'checkout_success.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedMethod = "visa";
  bool usePoints = false;
  final TextEditingController couponCtrl = TextEditingController();

  double subtotal = 29.99;
  double serviceFee = 0.03;
  double royalty = 0.05;
  double tax = 0.07;

  double get total {
    double t = subtotal +
        (subtotal * serviceFee) +
        (subtotal * royalty) +
        (subtotal * tax);

    if (usePoints) t -= 3.0; // user has 300 points = $3

    return t;
  }

  Widget paymentOption(String id, String label, IconData icon) {
    bool active = selectedMethod == id;

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textSoft),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body()),
            const Spacer(),
            if (active) Icon(Icons.check_circle, color: AppColors.primary)
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTextStyles.title() : AppTextStyles.caption()),
          Text("\$${value.toStringAsFixed(2)}",
              style: bold ? AppTextStyles.title() : AppTextStyles.body()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Checkout", style: AppTextStyles.heading()),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔹 Digital Ownership Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Digital Ownership", style: AppTextStyles.title()),
                const SizedBox(height: 8),
                Text("The assets will be added to your MetaZone Library instantly.",
                    style: AppTextStyles.caption()),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Payment Methods
          Text("Payment Method", style: AppTextStyles.title()),
          const SizedBox(height: 10),
          paymentOption("visa", "Visa / Mastercard", Icons.credit_card),
          paymentOption("paypal", "PayPal", Icons.account_balance_wallet),
          paymentOption("apple", "Apple Pay", Icons.phone_iphone),

          const SizedBox(height: 20),

          // 🔹 Coupon
          Text("Have a coupon?", style: AppTextStyles.title(size: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardSoft,
                    hintText: "Enter coupon code",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (couponCtrl.text.trim() == "META10") {
                    setState(() => subtotal *= 0.90);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coupon applied: 10% off")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid coupon")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text("Apply"),
              )
            ],
          ),

          const SizedBox(height: 20),

          // 🔹 Loyalty Points
          SwitchListTile(
            value: usePoints,
            onChanged: (v) => setState(() => usePoints = v),
            title: Text("Use MetaZone Points (300 pts = \$3)", style: AppTextStyles.body()),
            activeColor: AppColors.primary,
          ),

          const SizedBox(height: 20),

          // 🔹 Price Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                summaryRow("Subtotal", subtotal),
                summaryRow("Service Fee (3%)", subtotal * serviceFee),
                summaryRow("Royalty (5%)", subtotal * royalty),
                summaryRow("Tax (7%)", subtotal * tax),
                if (usePoints) summaryRow("Points Applied", -3.0),
                const Divider(height: 20),
                summaryRow("Total", total, bold: true),
              ],
            ),
          ),

          const SizedBox(height: 26),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutSuccessScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text("Complete Purchase"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
