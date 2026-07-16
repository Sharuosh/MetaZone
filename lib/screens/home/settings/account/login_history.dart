import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  final history = const [
    {"device": "Samsung S20", "time": "Today • 2:14 PM", "loc": "Cairo"},
    {"device": "iPad Mini", "time": "Yesterday • 9:33 AM", "loc": "Alex"},
    {"device": "Meta Glasses M1", "time": "3 days ago", "loc": "Cairo"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Login History"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: history.length,
        itemBuilder: (_, i) {
          return Card(
            color: AppColors.card,
            child: ListTile(
              leading:
              Icon(Icons.devices, color: AppColors.primary),
              title: Text(history[i]["device"]!),
              subtitle: Text("${history[i]["time"]} • ${history[i]["loc"]}"),
              trailing: TextButton(
                onPressed: () {},
                child: const Text("Revoke"),
              ),
            ),
          );
        },
      ),
    );
  }
}
