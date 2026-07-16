import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RegionSettingsScreen extends StatefulWidget {
  const RegionSettingsScreen({super.key});

  @override
  State<RegionSettingsScreen> createState() => _RegionSettingsScreenState();
}

class _RegionSettingsScreenState extends State<RegionSettingsScreen> {
  String _region = "Egypt";
  bool _use24h = true;
  bool _autoRegion = true;

  final List<String> regions = [
    "Egypt",
    "Saudi Arabia",
    "United Arab Emirates",
    "Qatar",
    "Kuwait",
    "USA",
    "UK",
    "Japan",
    "Germany",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Region Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Detect region automatically"),
            subtitle:
            const Text("Uses device GPS & system locale to detect region"),
            value: _autoRegion,
            onChanged: (v) => setState(() => _autoRegion = v),
          ),
          const SizedBox(height: 20),

          Text("Choose Region", style: AppTextStyles.title()),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonFormField<String>(
              value: _region,
              dropdownColor: AppColors.card,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              items: regions
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: _autoRegion ? null : (value) {
                setState(() => _region = value!);
              },
            ),
          ),

          const SizedBox(height: 25),

          Text("Time Format", style: AppTextStyles.title()),
          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text("Use 24-hour format"),
            subtitle: const Text("Example: 14:30 instead of 2:30 PM"),
            value: _use24h,
            onChanged: (v) => setState(() => _use24h = v),
          ),
        ],
      ),
    );
  }
}
