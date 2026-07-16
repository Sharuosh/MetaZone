import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      "Password changed • Today 2:00 PM",
      "Login from Galaxy S22 • Today 1:15 PM",
      "2FA enabled • Yesterday",
      "Email updated • Jan 24",
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Activity log", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: logs.map((l) {
          return Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.history, color: AppColors.primary),
              title: Text(l, style: AppTextStyles.body()),
            ),
          );
        }).toList(),
      ),
    );
  }
}
