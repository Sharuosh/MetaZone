import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MetadataPrivacyScreen extends StatefulWidget {
  const MetadataPrivacyScreen({super.key});

  @override
  State<MetadataPrivacyScreen> createState() => _MetadataPrivacyScreenState();
}

class _MetadataPrivacyScreenState extends State<MetadataPrivacyScreen> {
  bool hideLocation = false;
  bool hideTime = false;
  bool hideDevice = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Metadata privacy"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Hide exact location"),
              subtitle: const Text("Show only general area (city-level)"),
              value: hideLocation,
              onChanged: (v) => setState(() => hideLocation = v),
            ),
          ),
          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Hide timestamp"),
              subtitle: const Text("Remove creation time from AR objects"),
              value: hideTime,
              onChanged: (v) => setState(() => hideTime = v),
            ),
          ),
          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Hide device info"),
              subtitle: const Text("Hide device model used to place object"),
              value: hideDevice,
              onChanged: (v) => setState(() => hideDevice = v),
            ),
          ),
        ],
      ),
    );
  }
}
