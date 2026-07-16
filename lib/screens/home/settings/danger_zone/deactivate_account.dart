import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class DeactivateAccountScreen extends StatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  State<DeactivateAccountScreen> createState() => _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState extends State<DeactivateAccountScreen> {
  bool _stopNotifications = true;
  bool _hideProfile = true;

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account deactivated (demo)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Deactivate Account"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            "When you deactivate your account:",
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: 8),

          _info("• Your profile becomes hidden"),
          _info("• Your AR spots will not appear to others"),
          _info("• You can reactivate anytime by logging in"),

          const SizedBox(height: 20),
          SwitchListTile(
            value: _stopNotifications,
            title: const Text("Stop all notifications"),
            onChanged: (v) => setState(() => _stopNotifications = v),
          ),

          SwitchListTile(
            value: _hideProfile,
            title: const Text("Hide my profile immediately"),
            onChanged: (v) => setState(() => _hideProfile = v),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Deactivate Now"),
          )
        ],
      ),
    );
  }

  Widget _info(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: AppTextStyles.caption()),
    );
  }
}
