import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class AccountStatusScreen extends StatelessWidget {
  const AccountStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = "Active";
    final flags = [
      "Verified Email",
      "Phone Added",
      "No Violations",
      "Secure Login Enabled",
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Account Status"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.shield, color: AppColors.primary),
              title: Text("Status: $status"),
              subtitle: const Text("Your account is in good standing."),
            ),
          ),

          const SizedBox(height: 16),
          Text("Account Flags", style: AppTextStyles.title()),

          ...flags.map((f) => Card(
            color: AppColors.card,
            child: ListTile(
              leading:
              Icon(Icons.check_circle, color: AppColors.primary),
              title: Text(f),
            ),
          )),
        ],
      ),
    );
  }
}
