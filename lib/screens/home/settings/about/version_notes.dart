import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class VersionNotesScreen extends StatelessWidget {
  const VersionNotesScreen({super.key});

  final changes = const [
    {
      "v": "1.0.0",
      "list": [
        "Initial MetaZone AR system",
        "Core rendering pipeline",
        "Profile + Account systems",
        "AR Spots & world mapping"
      ]
    },
    {
      "v": "0.9.0",
      "list": [
        "New neon animation system",
        "Improved 3D depth layers",
        "Faster AR calibration"
      ]
    },
    {
      "v": "0.8.0",
      "list": [
        "Login + Register redesigned",
        "OTP + password recovery added",
        "Performance improvements"
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Version Notes"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...changes.map((c) {
            return Card(
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Version ${c['v']}", style: AppTextStyles.title()),
                    const SizedBox(height: 8),
                    ...(c['list'] as List<String>).map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(Icons.circle,
                              size: 6, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t, style: AppTextStyles.body())),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
