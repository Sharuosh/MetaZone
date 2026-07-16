// File: lib/screens/home/my_zones/my_zones_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MyZonesScreen extends StatelessWidget {
  const MyZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> zones = List.generate(5, (i) => {
      "id": "zone_$i",
      "title": "My Zone ${i + 1}",
      "image": "https://picsum.photos/seed/zone$i/1200/600",
      "visits": (i + 1) * 1500,
      "progress": 0.20 * (i + 1),
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("My Zones", style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.surface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: zones.length,
        itemBuilder: (ctx, i) {
          final z = zones[i];

          // ---------------- SAFE CASTING ----------------
          final String image = z["image"]?.toString() ?? "";
          final String title = z["title"]?.toString() ?? "Unknown Zone";
          final String visits = z["visits"]?.toString() ?? "0";
          final double progress =
          (z["progress"] is double) ? z["progress"] : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // ---- IMAGE ----
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: Image.network(
                    image,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: AppColors.surface,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ---- TEXT INFO ----
                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.title(size: 16)),
                        const SizedBox(height: 6),
                        Text("$visits visits",
                            style: AppTextStyles.caption()),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.surface.withOpacity(.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
