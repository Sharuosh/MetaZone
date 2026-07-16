import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TwoFAScreen extends StatefulWidget {
  const TwoFAScreen({super.key});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  bool sms = false;
  bool email = true;
  bool authenticator = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Two-Factor Authentication", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch(
            "SMS verification",
            "Receive login codes on your phone",
            sms,
                (v) => setState(() => sms = v),
          ),
          _switch(
            "Email verification",
            "Send codes to your recovery email",
            email,
                (v) => setState(() => email = v),
          ),
          _switch(
            "Authenticator App",
            "Use Google Authenticator or similar",
            authenticator,
                (v) => setState(() => authenticator = v),
          ),
        ],
      ),
    );
  }

  Widget _switch(String title, String sub, bool val, Function(bool) onChanged) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        value: val,
        onChanged: onChanged,
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
      ),
    );
  }
}
