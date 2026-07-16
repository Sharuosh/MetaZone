import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SystemAlertsScreen extends StatefulWidget {
  const SystemAlertsScreen({super.key});

  @override
  State<SystemAlertsScreen> createState() => _SystemAlertsScreenState();
}

class _SystemAlertsScreenState extends State<SystemAlertsScreen> {
  bool appUpdates = true;
  bool warnings = true;
  bool verification = true;

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
        title: const Text("System Alerts"),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("App Updates", "Major releases & improvements", appUpdates,
                  (v) => setState(() => appUpdates = v)),

          _switch("System Warnings", "Security issues, login attempts",
              warnings, (v) => setState(() => warnings = v)),

          _switch("Verification Alerts", "ID checks, status updates",
              verification, (v) => setState(() => verification = v)),
        ],
      ),
    );
  }
}
