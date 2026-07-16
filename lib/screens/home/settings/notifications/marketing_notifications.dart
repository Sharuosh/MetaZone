import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MarketingNotificationsScreen extends StatefulWidget {
  const MarketingNotificationsScreen({super.key});

  @override
  State<MarketingNotificationsScreen> createState() =>
      _MarketingNotificationsScreenState();
}

class _MarketingNotificationsScreenState
    extends State<MarketingNotificationsScreen> {
  bool newFeatures = true;
  bool promotions = false;
  bool announcements = true;

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
        backgroundColor: AppColors.surface,
        title: const Text("Marketing & Updates"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("New Features", "Feature releases & enhancements", newFeatures,
                  (v) => setState(() => newFeatures = v)),

          _switch("Promotions", "Offers, events, and partner deals", promotions,
                  (v) => setState(() => promotions = v)),

          _switch("Announcements", "General updates & news", announcements,
                  (v) => setState(() => announcements = v)),
        ],
      ),
    );
  }
}
