import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ResetDefaultsScreen extends StatelessWidget {
  const ResetDefaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Reset Defaults", style: AppTextStyles.heading()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Restore All Settings",
              style: AppTextStyles.title(size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "This will reset AR settings, appearance, notifications, privacy, and app preferences back to their original defaults.",
              style: AppTextStyles.caption(),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                "Your account, data, AR spots and sessions will NOT be deleted.\nOnly settings & preferences will be restored.",
                style: AppTextStyles.body(),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _confirm(context),
              child: const Text("Reset All Settings"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Reset Complete", style: AppTextStyles.heading()),
        content: const Text(
            "All app settings have been restored to their original defaults."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
