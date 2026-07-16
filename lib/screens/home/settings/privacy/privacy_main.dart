import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// Existing screens
import 'ar_visibility.dart';
import 'comment_permissions.dart';
import 'metadata_privacy.dart';
import 'privacy_presets.dart';
import 'location_precision.dart';
import 'blocked_accounts.dart'; // ⭐ مهم جداً

class PrivacyMainScreen extends StatelessWidget {
  const PrivacyMainScreen({super.key});

  Widget _item(BuildContext c, IconData icon, String title, String sub, Widget page) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSoft),
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
        title: Text("Privacy", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          _item(
            context,
            Icons.map,
            "AR Spots visibility",
            "Who can see your AR placements",
            const ARVisibilityScreen(),
          ),

          _item(
            context,
            Icons.comment,
            "Comment permissions",
            "Who can comment on your AR objects",
            const CommentPermissionsScreen(),
          ),

          _item(
            context,
            Icons.info_outline,
            "Metadata privacy",
            "Hide or show AR object metadata",
            const MetadataPrivacyScreen(),
          ),

          _item(
            context,
            Icons.location_on,
            "Location precision",
            "City only / Approximate / Exact",
            const LocationPrecisionScreen(),
          ),

          _item(
            context,
            Icons.lock,
            "Privacy presets",
            "Public / Friends / Restricted",
            const PrivacyPresetsScreen(),
          ),

          // ⭐ الإضافة الجديدة — مهمة جداً
          _item(
            context,
            Icons.block,
            "Blocked accounts",
            "Users you have blocked",
            const BlockedAccountsScreen(),
          ),
        ],
      ),
    );
  }
}
