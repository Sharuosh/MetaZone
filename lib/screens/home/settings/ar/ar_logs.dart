import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARLogsScreen extends StatefulWidget {
  const ARLogsScreen({super.key});

  @override
  State<ARLogsScreen> createState() => _ARLogsScreenState();
}

class _ARLogsScreenState extends State<ARLogsScreen> {
  bool logsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("AR Logs", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            "Collect AR debugging data such as anchor states, plane detection details, and motion updates.",
            style: AppTextStyles.caption(),
          ),

          const SizedBox(height: 20),

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Enable AR Logs"),
              subtitle: const Text("Used for debugging AR issues"),
              value: logsEnabled,
              onChanged: (v) => setState(() => logsEnabled = v),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48)),
            onPressed: () {},
            child: const Text("Export Logs"),
          ),
        ],
      ),
    );
  }
}
