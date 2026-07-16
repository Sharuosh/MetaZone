import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SecurityRecommendationsScreen extends StatelessWidget {
  const SecurityRecommendationsScreen({super.key});

  Widget _card(String title, String desc, IconData icon, Color color) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(desc, style: AppTextStyles.caption()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Security Recommendations", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _card(
            "Enable Two-Factor Authentication",
            "Your account will be more secure with 2FA enabled.",
            Icons.verified_user,
            Colors.orange,
          ),
          _card(
            "Review Trusted Devices",
            "Remove devices you no longer use.",
            Icons.devices,
            Colors.blue,
          ),
          _card(
            "Strengthen Your Password",
            "Use a longer password with letters, numbers and symbols.",
            Icons.lock,
            Colors.redAccent,
          ),
          _card(
            "Turn On App Lock",
            "Add an extra layer of security using PIN or biometrics.",
            Icons.phonelink_lock,
            AppColors.primary,
          ),
        ],
      ),
    );
  }
}
