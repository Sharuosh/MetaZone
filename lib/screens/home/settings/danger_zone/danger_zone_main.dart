// File: danger_zone_main.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

import 'export_before_delete.dart';
import 'deactivate_account.dart';
import 'final_delete_confirm.dart';

class DangerZoneMainScreen extends StatelessWidget {
  const DangerZoneMainScreen({super.key});

  Widget _item(
      BuildContext ctx,
      IconData icon,
      String title,
      String sub,
      Widget page,
      Color color,
      ) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSoft),
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text("Danger Zone", style: AppTextStyles.heading(size: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ---------------------------------------------
          // EXPORT ACCOUNT DATA
          // ---------------------------------------------
          _item(
            context,
            Icons.download,
            "Export Your Data",
            "Download AR spots, chats, sessions and account info",
            const ExportBeforeDeleteScreen(),
            AppColors.primary,
          ),

          // ---------------------------------------------
          // TEMPORARILY DEACTIVATE
          // ---------------------------------------------
          _item(
            context,
            Icons.pause_circle_filled,
            "Temporarily Deactivate",
            "Hide your profile and stop activity",
            const DeactivateAccountScreen(),
            Colors.orangeAccent,
          ),

          // ---------------------------------------------
          // PERMANENT DELETION (FULL FLOW)
          // ---------------------------------------------
          _item(
            context,
            Icons.delete_forever,
            "Delete Account Permanently",
            "This action cannot be undone",
            const FinalDeleteConfirmScreen(),
            AppColors.danger,
          ),

          const SizedBox(height: 25),

          _warningBox(),
        ],
      ),
    );
  }

  // --------------------------------------------------
  //   EXTRA VISUAL WARNING BOX
  // --------------------------------------------------
  Widget _warningBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.card.withOpacity(0.4),
        border: Border.all(color: AppColors.danger.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "⚠ Read Before Continuing",
            style: AppTextStyles.title(size: 16).copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: 10),
          Text(
            "Actions in this section are sensitive. "
                "Some actions may permanently remove your AR data, profile "
                "and world interactions. Proceed with caution.",
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}
