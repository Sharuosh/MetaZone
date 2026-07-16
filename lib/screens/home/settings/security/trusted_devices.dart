import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TrustedDevicesScreen extends StatefulWidget {
  const TrustedDevicesScreen({super.key});

  @override
  State<TrustedDevicesScreen> createState() => _TrustedDevicesScreenState();
}

class _TrustedDevicesScreenState extends State<TrustedDevicesScreen> {
  List<Map<String, String>> devices = [
    {"name": "Galaxy S22", "last": "Today, 2:10 PM"},
    {"name": "Meta Glasses 2", "last": "Yesterday, 6:50 PM"},
    {"name": "iPad Pro 12", "last": "Jan 23, 11:00 AM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Trusted devices", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: devices.map((d) {
          return Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.devices_other, color: AppColors.primary),
              title: Text(d["name"]!, style: AppTextStyles.body()),
              subtitle: Text("Last active: ${d["last"]!}",
                  style: AppTextStyles.caption()),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle, color: AppColors.danger),
                onPressed: () => setState(() => devices.remove(d)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
