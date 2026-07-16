import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARWorldAlertsScreen extends StatefulWidget {
  const ARWorldAlertsScreen({super.key});

  @override
  State<ARWorldAlertsScreen> createState() => _ARWorldAlertsScreenState();
}

class _ARWorldAlertsScreenState extends State<ARWorldAlertsScreen> {
  bool nearbyZones = true;
  bool newSpots = true;
  bool dangerZones = false;
  bool teleportEvents = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("AR World Alerts"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("Nearby AR Zones", "Alerts when entering AR active areas", nearbyZones,
                  (v) => setState(() => nearbyZones = v)),

          _switch("New AR Spots", "Notify when new AR objects appear around you", newSpots,
                  (v) => setState(() => newSpots = v)),

          _switch("Danger Zones", "Areas with unstable AR tracking", dangerZones,
                  (v) => setState(() => dangerZones = v)),

          _switch("Teleporter events", "When teleporters activate near you", teleportEvents,
                  (v) => setState(() => teleportEvents = v)),
        ],
      ),
    );
  }

  Widget _switch(String title, String sub, bool val, Function(bool) onChanged) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        value: val,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(sub, style: AppTextStyles.caption()),
      ),
    );
  }
}
