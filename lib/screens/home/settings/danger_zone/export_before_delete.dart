import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ExportBeforeDeleteScreen extends StatefulWidget {
  final bool isDeleteFlow;

  const ExportBeforeDeleteScreen({super.key, this.isDeleteFlow = false});

  @override
  State<ExportBeforeDeleteScreen> createState() => _ExportBeforeDeleteScreenState();
}

class _ExportBeforeDeleteScreenState extends State<ExportBeforeDeleteScreen> {
  bool _exportAR = true;
  bool _exportProfile = true;
  bool _exportSessions = false;

  void _export() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Export started (demo)")),
    );
  }

  void _deleteAccountPermanently() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          "Delete Account?",
          style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
        ),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted (demo)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.isDeleteFlow ? "Delete Account" : "Export Your Data"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            widget.isDeleteFlow
                ? "Before deleting, you may export your AR data:"
                : "Choose which data you want to export:",
            style: AppTextStyles.body(),
          ),

          const SizedBox(height: 20),

          SwitchListTile(
            value: _exportAR,
            title: const Text("AR Spots & Objects"),
            subtitle: const Text("Your placed content, metadata, interactions"),
            onChanged: (v) => setState(() => _exportAR = v),
          ),

          SwitchListTile(
            value: _exportProfile,
            title: const Text("Profile Information"),
            subtitle: const Text("Name, username, bio, connections"),
            onChanged: (v) => setState(() => _exportProfile = v),
          ),

          SwitchListTile(
            value: _exportSessions,
            title: const Text("Login Sessions"),
            subtitle: const Text("Active & historical devices"),
            onChanged: (v) => setState(() => _exportSessions = v),
          ),

          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _export,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Export Now"),
          ),

          if (widget.isDeleteFlow) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteAccountPermanently,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text("Delete Account Permanently"),
            ),
          ]
        ],
      ),
    );
  }
}
