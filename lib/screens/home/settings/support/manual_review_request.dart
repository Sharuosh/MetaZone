import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ManualReviewRequestScreen extends StatefulWidget {
  const ManualReviewRequestScreen({super.key});

  @override
  State<ManualReviewRequestScreen> createState() =>
      _ManualReviewRequestScreenState();
}

class _ManualReviewRequestScreenState
    extends State<ManualReviewRequestScreen> {
  final TextEditingController _reason = TextEditingController();
  final TextEditingController _links = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Manual Review Request", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Why do you want a manual review?",
            style: AppTextStyles.title(size: 18),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _reason,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Explain your request",
              filled: true,
              fillColor: AppColors.cardSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "Relevant Links (Optional)",
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: 6),

          TextField(
            controller: _links,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: "AR spots, posts, media",
              filled: true,
              fillColor: AppColors.cardSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 25),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              _submit(context);
            },
            child: const Text("Submit Request"),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Submitted", style: AppTextStyles.heading()),
        content: const Text(
            "Your request has been sent to the MetaZone moderation team."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
