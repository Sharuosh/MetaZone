import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class DailyDigestScreen extends StatefulWidget {
  const DailyDigestScreen({super.key});

  @override
  State<DailyDigestScreen> createState() => _DailyDigestScreenState();
}

class _DailyDigestScreenState extends State<DailyDigestScreen> {
  bool enabled = true;
  bool includeSpots = true;
  bool includeFollowers = true;
  bool includeSystemUpdates = true;
  String time = "9:00 AM";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Daily Digest"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.card,
            child: SwitchListTile(
              value: enabled,
              onChanged: (v) => setState(() => enabled = v),
              title: const Text("Enable daily digest"),
              subtitle: const Text("Daily summary of your MetaZone activity"),
            ),
          ),

          _switch("Include AR Spots", includeSpots,
                  (v) => setState(() => includeSpots = v)),

          _switch("Include Followers updates", includeFollowers,
                  (v) => setState(() => includeFollowers = v)),

          _switch("Include System updates", includeSystemUpdates,
                  (v) => setState(() => includeSystemUpdates = v)),

          const SizedBox(height: 14),
          ListTile(
            title: const Text("Delivery time"),
            subtitle: Text(time),
            trailing: ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                    context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));

                if (picked != null) {
                  setState(() => time = picked.format(context));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Change"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switch(String title, bool val, Function(bool) on) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        title: Text(title),
        value: val,
        onChanged: on,
      ),
    );
  }
}
