import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final _detailsCtrl = TextEditingController();
  bool _includeLogs = true;
  bool _includeARFeed = false;

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bug report submitted (demo)")),
    );
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Report a Problem"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text("Describe the issue:", style: AppTextStyles.body()),
          const SizedBox(height: 8),

          TextField(
            controller: _detailsCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardSoft,
              hintText: "What happened? Steps to reproduce…",
            ),
          ),

          const SizedBox(height: 16),
          SwitchListTile(
            value: _includeLogs,
            title: const Text("Include system logs"),
            subtitle: const Text("Helps debug crashes & AR failures"),
            onChanged: (v) => setState(() => _includeLogs = v),
          ),

          SwitchListTile(
            value: _includeARFeed,
            title: const Text("Attach AR camera-icon feed (auto-capture)"),
            subtitle: const Text("Useful for tracking / calibration issues"),
            onChanged: (v) => setState(() => _includeARFeed = v),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Submit Report"),
          ),
        ],
      ),
    );
  }
}
