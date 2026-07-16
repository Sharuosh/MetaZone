import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  String status = "Not Verified";

  void _start() {
    setState(() {
      status = "Pending";
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Verification started")));
  }

  void _cancel() {
    setState(() {
      status = "Not Verified";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Identity Verification"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.verified_user, color: AppColors.primary),
              title: Text("Status: $status"),
            ),
          ),

          const SizedBox(height: 20),

          if (status == "Not Verified")
            ElevatedButton(
              onPressed: _start,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Start Verification"),
            ),

          if (status == "Pending")
            ElevatedButton(
              onPressed: _cancel,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text("Cancel Request"),
            ),
        ],
      ),
    );
  }
}
