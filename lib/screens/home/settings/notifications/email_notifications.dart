import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EmailNotificationsScreen extends StatefulWidget {
  const EmailNotificationsScreen({super.key});

  @override
  State<EmailNotificationsScreen> createState() =>
      _EmailNotificationsScreenState();
}

class _EmailNotificationsScreenState extends State<EmailNotificationsScreen> {
  bool summaries = false;
  bool security = true;
  bool marketing = false;

  Widget _switch(String title, String sub, bool v, Function(bool) onChange) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(sub),
        value: v,
        onChanged: onChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Email Notifications"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("Activity Summary", "Daily or weekly email reports", summaries,
                  (v) => setState(() => summaries = v)),

          _switch("Security Alerts", "Password changes, suspicious logins",
              security, (v) => setState(() => security = v)),

          _switch("Marketing Emails", "New features & partner promotions",
              marketing, (v) => setState(() => marketing = v)),
        ],
      ),
    );
  }
}
