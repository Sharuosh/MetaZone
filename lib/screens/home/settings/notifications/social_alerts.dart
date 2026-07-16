import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SocialAlertsScreen extends StatefulWidget {
  const SocialAlertsScreen({super.key});

  @override
  State<SocialAlertsScreen> createState() => _SocialAlertsScreenState();
}

class _SocialAlertsScreenState extends State<SocialAlertsScreen> {
  bool likes = true;
  bool comments = true;
  bool follows = true;
  bool mentions = true;

  Widget _switch(String title, String sub, bool v, Function(bool) onChange) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(sub),
        value: v,
        onChanged: onChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Social Notifications"),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("Likes", "Get alerts when someone likes your AR objects",
              likes, (v) => setState(() => likes = v)),

          _switch("Comments", "New comments on your AR content", comments,
                  (v) => setState(() => comments = v)),

          _switch("New Followers", "Someone followed your profile", follows,
                  (v) => setState(() => follows = v)),

          _switch("Mentions", "When someone tags your username", mentions,
                  (v) => setState(() => mentions = v)),
        ],
      ),
    );
  }
}
