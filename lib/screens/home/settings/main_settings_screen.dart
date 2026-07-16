// File: lib/screens/settings/main_settings_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// -------------------------------
// ACCOUNT
// -------------------------------
import 'account/account_information.dart';
import 'account/account_status.dart';
import 'account/login_history.dart';
import 'account/linked_accounts.dart';
import 'account/identity_verification.dart';
import 'account/data_download.dart';

// -------------------------------
// SECURITY
// -------------------------------
import 'security/security_main.dart';

// -------------------------------
// PRIVACY
// -------------------------------
import 'privacy/privacy_main.dart';
import 'privacy/blocked_accounts.dart';
import 'privacy/location_precision.dart';

// -------------------------------
// AR
// -------------------------------
import 'ar/ar_settings_main.dart';
import 'ar/motion_prediction.dart';
import 'ar/plane_classification.dart';
import 'ar/ar_safe_mode.dart';
import 'ar/ar_logs.dart';

// -------------------------------
// NOTIFICATIONS
// -------------------------------
import 'notifications/notifications_main.dart';

// -------------------------------
// APPEARANCE
// -------------------------------
import 'appearance/appearance_main.dart';
import 'appearance/glass_morphism.dart';
import 'appearance/texture_sharpness.dart';
import 'appearance/animation_speed.dart';

// -------------------------------
// STORAGE
// -------------------------------
import 'storage/storage_main.dart';
import 'storage/reset_defaults.dart';

// -------------------------------
// SUPPORT
// -------------------------------
import 'support/support_main.dart';
import 'support/known_issues.dart';
import 'support/manual_review_request.dart';

// -------------------------------
// ABOUT
// -------------------------------
import 'about/about_main.dart';
import 'about/build_number.dart';

// -------------------------------
// LANGUAGE
// -------------------------------
import 'language/language_main.dart';   // ← مهم
import 'language/region_settings.dart';
import 'language/font_localization.dart';
import 'language/localization_debug.dart';

// -------------------------------
// DANGER ZONE
// -------------------------------
import 'danger_zone/danger_zone_main.dart';

class MainSettingsScreen extends StatelessWidget {
  const MainSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          "Settings",
          style: AppTextStyles.heading(size: 20),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 20),

          // -------------------------
          // ACCOUNT
          // -------------------------
          _title("Account & Profile"),
          _item(context, Icons.person, "Account Information",
              "Profile, username, bio, email", AccountInformationScreen()),
          _item(context, Icons.shield, "Account Status",
              "Verification, flags", AccountStatusScreen()),
          _item(context, Icons.history, "Login History",
              "Sessions, device types, IP logs", LoginHistoryScreen()),
          _item(context, Icons.link, "Linked Accounts",
              "Google / Facebook / Apple", LinkedAccountsScreen()),
          _item(context, Icons.verified_user, "Identity Verification",
              "Upload ID, verification steps",
              IdentityVerificationScreen()),
          _item(context, Icons.download, "Data Download Request",
              "Get a copy of your MetaZone data",
              DataDownloadScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // SECURITY
          // -------------------------
          _title("Security"),
          _item(context, Icons.security, "Security Center",
              "Password, 2FA, trusted devices", SecurityMainScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // PRIVACY
          // -------------------------
          _title("Privacy"),
          _item(context, Icons.privacy_tip, "Privacy Controls",
              "Visibility, permissions", PrivacyMainScreen()),
          _item(context, Icons.block, "Blocked Accounts",
              "Manage blocked users", BlockedAccountsScreen()),
          _item(context, Icons.location_on, "Location Precision",
              "City-only / Approximate / Exact",
              LocationPrecisionScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // AR GROUP
          // -------------------------
          _title("AR & Performance"),
          _item(context, Icons.view_in_ar, "AR Settings",
              "Engine, tracking, calibration", ArSettingsMainScreen()),
          _item(context, Icons.multitrack_audio, "Motion Prediction",
              "Improve stability & tracking", MotionPredictionScreen()),
          _item(context, Icons.stairs, "Plane Classification",
              "Detect floor / walls / tables",
              PlaneClassificationScreen()),
          _item(context, Icons.security, "AR Safe Mode",
              "Safety layer in AR world", ARSafeModeScreen()),   // ← تم التعديل
          _item(context, Icons.bug_report, "AR Logs",
              "Enable AR engine logging", ARLogsScreen()),        // ← تم التعديل

          const SizedBox(height: 15),

          // -------------------------
          // NOTIFICATIONS
          // -------------------------
          _title("Notifications"),
          _item(context, Icons.notifications_active, "Notifications Control",
              "Sounds, alerts, AR events", NotificationsMainScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // APPEARANCE
          // -------------------------
          _title("Appearance"),
          _item(context, Icons.color_lens, "Appearance",
              "Theme, neon, depth", AppearanceMainScreen()),
          _item(context, Icons.blur_on, "Glass Morphism",
              "Glass intensity & blur", GlassMorphismScreen()),
          _item(context, Icons.texture, "Texture Sharpness",
              "Improve UI clarity", TextureSharpnessScreen()),
          _item(context, Icons.speed, "Animation Speed",
              "Smoothness & performance", AnimationSpeedScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // STORAGE
          // -------------------------
          _title("Storage & Data"),
          _item(context, Icons.storage, "Storage Management",
              "Caches, offline files", StorageMainScreen()),
          _item(context, Icons.restore, "Reset App Defaults",
              "Restore factory settings", ResetDefaultsScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // LANGUAGE
          // -------------------------
          _title("Language & Region"),
          _item(context, Icons.language, "Language",
              "Choose app language", LanguageMainScreen()),   // ← تم التعديل
          _item(context, Icons.public, "Region Settings",
              "Time, units, locale", RegionSettingsScreen()),
          _item(context, Icons.font_download, "Font Localization",
              "Arabic / English font settings", FontLocalizationScreen()),
          _item(context, Icons.bug_report, "Localization Debug",
              "Developer translation tools",
              LocalizationDebugScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // SUPPORT
          // -------------------------
          _title("Support Center"),
          _item(context, Icons.support_agent, "Help & Support",
              "Bug reports, tutorials", SupportMainScreen()),
          _item(context, Icons.warning, "Known Issues",
              "Active problems list", KnownIssuesScreen()),
          _item(context, Icons.fact_check, "Manual Review Request",
              "Request account or AR review",
              ManualReviewRequestScreen()),

          const SizedBox(height: 15),

          // -------------------------
          // ABOUT
          // -------------------------
          _title("About"),
          _item(context, Icons.info_outline, "About MetaZone",
              "Team, version, stack", AboutMainScreen()),
          _item(context, Icons.confirmation_number, "Build Number",
              "Internal app build details", BuildNumberScreen()),

          const SizedBox(height: 20),

          _danger(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // UI BLOCKS
  // ---------------------------------------------------

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: const AssetImage("assets/images/user.png"),
            backgroundColor: AppColors.primary.withOpacity(.1),
          ),
          const SizedBox(height: 10),

          Text("Abdelrahman Sharuosh",
              style: AppTextStyles.title(size: 18)),
          Text("abdel@metazone.app",
              style: AppTextStyles.caption()),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AccountInformationScreen())),
                child: const Text("Manage Account"),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LoginHistoryScreen())),
                child: const Text("Devices"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.heading(size: 15)),
    );
  }

  Widget _item(
      BuildContext ctx, IconData icon, String title, String sub, Widget route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSoft),
        onTap: () => Navigator.push(
            ctx, MaterialPageRoute(builder: (_) => route)),
      ),
    );
  }

  Widget _danger(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.delete_forever, color: AppColors.danger),
        title: Text("Danger Zone",
            style: TextStyle(
                color: AppColors.danger, fontWeight: FontWeight.w700)),
        subtitle: Text(
            "Delete account, deactivation, export backup",
            style: AppTextStyles.caption()),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => DangerZoneMainScreen())),
      ),
    );
  }
}
