import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PrivacyPresetsScreen extends StatefulWidget {
  const PrivacyPresetsScreen({super.key});

  @override
  State<PrivacyPresetsScreen> createState() => _PrivacyPresetsScreenState();
}

class _PrivacyPresetsScreenState extends State<PrivacyPresetsScreen> {
  String preset = "Friends";

  @override
  Widget build(BuildContext context) {
    final presets = {
      "Public": "Anyone can view your AR objects & profile",
      "Friends": "Followers only, safer for social use",
      "Restricted": "Only approved users see anything",
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Privacy presets"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: presets.entries.map((e) {
          return Card(
            color: AppColors.card,
            child: RadioListTile<String>(
              value: e.key,
              groupValue: preset,
              onChanged: (v) => setState(() => preset = v!),
              title: Text(e.key, style: AppTextStyles.title()),
              subtitle: Text(e.value, style: AppTextStyles.caption()),
            ),
          );
        }).toList(),
      ),
    );
  }
}
