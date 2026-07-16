import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// AR notifications
import 'ar_world_alerts.dart';
import 'daily_digest.dart';
import 'event_prompts.dart';

// NEW notification categories
import 'system_alerts.dart';
import 'social_alerts.dart';
import 'marketing_notifications.dart';
import 'email_notifications.dart';

class NotificationsMainScreen extends StatefulWidget {
  const NotificationsMainScreen({super.key});

  @override
  State<NotificationsMainScreen> createState() => _NotificationsMainScreenState();
}

class _NotificationsMainScreenState extends State<NotificationsMainScreen> {
  bool push = true;
  bool vibration = true;

  // Toggles for categories
  bool systemAlerts = true;
  bool socialAlerts = true;
  bool marketing = false;
  bool emailNotifications = false;

  String sound = "Default";

  Widget _item(BuildContext c, IconData icon, String title, String sub, Widget page) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  Widget _switch(String title, String sub, bool value, void Function(bool) onChanged, {IconData? icon}) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        secondary: icon != null ? Icon(icon, color: AppColors.primary) : null,
        title: Text(title),
        subtitle: Text(sub),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Notifications", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // GLOBAL CONTROL
          _switch(
            "Push notifications",
            "Enable or disable all MetaZone notifications",
            push,
                (v) => setState(() => push = v),
            icon: Icons.notifications_active,
          ),

          _switch(
            "Vibration",
            "Haptic feedback for alerts",
            vibration,
                (v) => setState(() => vibration = v),
            icon: Icons.vibration,
          ),

          const SizedBox(height: 10),

          // NAVIGATION ITEMS
          _item(
            context,
            Icons.warning_amber,
            "System Alerts",
            "App status, verification, warnings",
            const SystemAlertsScreen(),
          ),

          _item(
            context,
            Icons.people,
            "Social Notifications",
            "Likes, comments, follows, mentions",
            const SocialAlertsScreen(),
          ),

          _item(
            context,
            Icons.campaign,
            "Marketing & Updates",
            "Announcements and feature releases",
            const MarketingNotificationsScreen(),
          ),

          _item(
            context,
            Icons.email_outlined,
            "Email Notifications",
            "Receive updates via email",
            const EmailNotificationsScreen(),
          ),

          const SizedBox(height: 16),

          // SOUND
          ListTile(
            title: const Text("Notification sound"),
            subtitle: Text(sound),
            trailing: ElevatedButton(
              onPressed: () async {
                final chosen = await showDialog<String>(
                  context: context,
                  builder: (_) => SimpleDialog(
                    backgroundColor: AppColors.surface,
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, "Default"),
                        child: const Text("Default"),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, "Chime"),
                        child: const Text("Chime"),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, "Beep"),
                        child: const Text("Beep"),
                      ),
                    ],
                  ),
                );
                if (chosen != null) setState(() => sound = chosen);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Change"),
            ),
          ),

          const SizedBox(height: 20),

          // AR NOTIFICATIONS
          _item(
            context,
            Icons.public,
            "AR World Alerts",
            "Alerts based on AR zones & surroundings",
            const ARWorldAlertsScreen(),
          ),

          _item(
            context,
            Icons.calendar_month,
            "Daily Digest",
            "Summary of your recent activity & AR events",
            const DailyDigestScreen(),
          ),

          _item(
            context,
            Icons.lightbulb,
            "First-time Event Prompts",
            "Tips when discovering new features",
            const EventPromptsScreen(),
          ),
        ],
      ),
    );
  }
}
