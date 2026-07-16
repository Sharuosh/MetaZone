import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EventPromptsScreen extends StatefulWidget {
  const EventPromptsScreen({super.key});

  @override
  State<EventPromptsScreen> createState() => _EventPromptsScreenState();
}

class _EventPromptsScreenState extends State<EventPromptsScreen> {
  bool firstTimeAR = true;
  bool firstTeleporter = true;
  bool firstWorldZone = true;
  bool recommendFeatures = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("First-time Prompts"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("AR Feature Intro", "Show help when using AR for the first time",
              firstTimeAR, (v) => setState(() => firstTimeAR = v)),

          _switch("Teleporter intro", "Show teleport tutorial when discovered",
              firstTeleporter, (v) => setState(() => firstTeleporter = v)),

          _switch("World Zones intro", "Hint when entering your first AR Zone",
              firstWorldZone, (v) => setState(() => firstWorldZone = v)),

          _switch("Recommended features",
              "Suggest features based on usage patterns",
              recommendFeatures, (v) => setState(() => recommendFeatures = v)),
        ],
      ),
    );
  }

  Widget _switch(String title, String sub, bool val, Function(bool) on) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        value: val,
        onChanged: on,
        title: Text(title),
        subtitle: Text(sub, style: AppTextStyles.caption()),
      ),
    );
  }
}
