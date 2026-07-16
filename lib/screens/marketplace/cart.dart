import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'product_details.dart';
import 'preview_ar.dart';

class CartItem {
  final String id;
  final String title;
  final String type; // Portal, 3D Object, Hologram…
  final String thumbnail;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.type,
    required this.thumbnail,
    required this.price,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cart = [
    CartItem(
      id: "p1",
      title: "Cyber Neon Portal",
      type: "Portal Asset",
      thumbnail: "assets/market/portal.png",
      price: 4.99,
    ),
    CartItem(
      id: "p2",
      title: "Floating Hologram Statue",
      type: "Hologram",
      thumbnail: "assets/market/holo.png",
      price: 2.49,
    ),
  ];

  // MetaZone system fees
  double get subtotal => cart.fold(0, (sum, item) => sum + item.price);

  double get serviceFee => subtotal * 0.03;
  double get creatorRoyalty => subtotal * 0.05;
  double get tax => subtotal * 0.07;

  double get total => subtotal + serviceFee + creatorRoyalty + tax;

  void removeItem(String id) {
    setState(() {
      cart.removeWhere((item) => item.id == id);
    });
  }

  Widget itemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(item.thumbnail),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(item.title, style: AppTextStyles.title()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.type, style: AppTextStyles.caption()),
            const SizedBox(height: 4),

            // ---- FIXED HERE ----
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreviewARScreen(
                      productTitle: item.title,
                      productModel3D: item.thumbnail,
                      price: item.price,
                    ),
                  ),
                );
              },
              child: Text(
                "Preview in AR",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("\$${item.price}", style: AppTextStyles.body()),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => removeItem(item.id),
              child: Icon(Icons.delete_forever, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: bold ? AppTextStyles.title() : AppTextStyles.caption(),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: bold ? AppTextStyles.title() : AppTextStyles.body(),
          ),
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
        title: Text("Your Cart", style: AppTextStyles.heading()),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              onPressed: () => setState(() => cart.clear()),
              icon: Icon(Icons.delete, color: AppColors.danger),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
        child: Text(
          "Your cart is empty.",
          style: AppTextStyles.caption(),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...cart.map(itemCard).toList(),
          const SizedBox(height: 20),

          // ---- SUMMARY BOX ----
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
                summaryRow("MetaZone Service Fee (3%)", serviceFee),
                summaryRow("Creator Royalty (5%)", creatorRoyalty),
                summaryRow("Estimated Tax (7%)", tax),
                const Divider(height: 20),
                summaryRow("Total", total, bold: true),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/checkout");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text("Continue to Checkout"),
          ),
        ],
      ),
    );
  }
}
