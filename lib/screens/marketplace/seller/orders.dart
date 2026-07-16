// File: lib/screens/marketplace/seller/orders.dart
// MetaZone — Digital Orders Center for AR Marketplace

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Demo orders
  List<Map<String, dynamic>> _orders = [
    {
      "id": "o1",
      "buyer": "Mohamed Salah",
      "product": "Sci-Fi Portal",
      "price": 25.0,
      "status": "Paid",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": "o2",
      "buyer": "Nour Ahmed",
      "product": "Hologram Sphere",
      "price": 15.0,
      "status": "Pending",
      "date": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": "o3",
      "buyer": "Kareem Adel",
      "product": "AR Light Beam Pack",
      "price": 8.0,
      "status": "Refunded",
      "date": DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  Color _statusColor(String s) {
    switch (s) {
      case "Paid":
        return Colors.greenAccent;
      case "Pending":
        return Colors.orangeAccent;
      case "Refunded":
        return AppColors.danger;
      default:
        return AppColors.textSoft;
    }
  }

  void _openOrderDetails(Map order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Order Details", style: AppTextStyles.heading()),
          const SizedBox(height: 16),

          Text("Product: ${order["product"]}", style: AppTextStyles.title()),
          const SizedBox(height: 6),

          Text("Buyer: ${order["buyer"]}", style: AppTextStyles.body()),
          const SizedBox(height: 6),

          Text("Price: \$${order["price"]}", style: AppTextStyles.body()),
          const SizedBox(height: 6),

          Text("Status: ${order["status"]}",
              style: AppTextStyles.body(color: _statusColor(order["status"]))),
          const SizedBox(height: 6),

          Text("Date: ${order["date"].toLocal().toString().split('.').first}",
              style: AppTextStyles.caption()),
          const SizedBox(height: 20),

          if (order["status"] == "Paid")
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Refund issued (demo)")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              icon: const Icon(Icons.undo),
              label: const Text("Issue Refund"),
            ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Update sent to buyer (demo)")));
            },
            icon: const Icon(Icons.send),
            label: const Text("Send Update to Buyer"),
          ),

          const SizedBox(height: 10),
        ]),
      ),
    );
  }

  Widget _orderCard(Map order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(.2),
          child: const Icon(Icons.view_in_ar, color: Colors.white),
        ),
        title: Text(order["product"], style: AppTextStyles.title()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Buyer: ${order["buyer"]}", style: AppTextStyles.caption(size: 12)),
            const SizedBox(height: 4),
            Text("Date: ${order["date"].toLocal().toString().split('.').first}",
                style: AppTextStyles.caption(size: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("\$${order["price"]}", style: AppTextStyles.body()),
            const SizedBox(height: 6),
            Text(order["status"],
                style: AppTextStyles.caption(
                    color: _statusColor(order["status"]), size: 12)),
          ],
        ),
        onTap: () => _openOrderDetails(order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Orders", style: AppTextStyles.heading()),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (_, i) => _orderCard(_orders[i]),
      ),
    );
  }
}
