// File: lib/screens/settings/support/support_main.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// Import all support screens that may exist in the folder
import 'report_bug.dart';
import 'tutorials.dart';
import 'contact_support.dart';
import 'manual_review_request.dart';
import 'known_issues.dart';

class SupportMainScreen extends StatelessWidget {
  const SupportMainScreen({super.key});

  Widget _item(
      BuildContext c,
      IconData icon,
      String title,
      String sub,
      Widget page,
      ) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Support & Help", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _item(
            context,
            Icons.bug_report,
            "Report a Problem",
            "Send logs, screenshots, AR camera-icon feed",
            const ReportBugScreen(),
          ),

          _item(
            context,
            Icons.school,
            "Tutorials & Guides",
            "Learn how MetaZone & AR works",
            const TutorialsScreen(),
          ),

          _item(
            context,
            Icons.support_agent,
            "Contact Support",
            "Email, Discord, X (Twitter)",
            const ContactSupportScreen(),
          ),

          _item(
            context,
            Icons.verified_user,
            "Request Manual Review",
            "Submit profile or AR content for human moderation",
            const ManualReviewRequestScreen(),
          ),

          // Known issues / status page
          _item(
            context,
            Icons.error_outline,
            "Known Issues",
            "Current incidents, fixes and workarounds",
            const KnownIssuesScreen(),
          ),
        ],
      ),
    );
  }
}
