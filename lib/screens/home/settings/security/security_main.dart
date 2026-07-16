import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// Existing screens
import 'change_password.dart';
import 'two_fa.dart';
import 'recovery_email.dart';
import 'trusted_devices.dart';
import 'activity_log.dart';

// Newly added screens
import 'app_lock.dart';
import 'security_recommendations.dart';

class SecurityMainScreen extends StatelessWidget {
  const SecurityMainScreen({super.key});

  Widget _item(BuildContext c, IconData icon, String title, String sub, Widget page) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSoft),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Security", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          // 🔐 Security Recommendations
          _item(
            context,
            Icons.shield,
            "Security Recommendations",
            "Improve your account protection",
            const SecurityRecommendationsScreen(),
          ),

          // 🔑 Change Password
          _item(
            context,
            Icons.lock,
            "Change Password",
            "Update your login password",
            const ChangePasswordScreen(),
          ),

          // 🔒 Two Factor Authentication
          _item(
            context,
            Icons.verified_user,
            "Two-Factor Authentication",
            "Add an extra login protection layer",
            const TwoFAScreen(),
          ),

          // 📧 Recovery Email
          _item(
            context,
            Icons.email_outlined,
            "Recovery Email",
            "Backup email for account recovery",
            const RecoveryEmailScreen(),
          ),

          // 🖥 Trusted Devices
          _item(
            context,
            Icons.devices,
            "Trusted Devices",
            "Manage logged-in devices",
            const TrustedDevicesScreen(),
          ),

          // 📜 Activity Log
          _item(
            context,
            Icons.history,
            "Activity Log",
            "Recent login & security events",
            const ActivityLogScreen(),
          ),

          // 🔐 App Lock (PIN / Biometrics)
          _item(
            context,
            Icons.phonelink_lock,
            "App Lock",
            "PIN, Pattern, Biometrics",
            const AppLockScreen(),
          ),
        ],
      ),
    );
  }
}
