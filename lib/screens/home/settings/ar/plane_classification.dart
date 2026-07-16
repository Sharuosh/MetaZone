import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PlaneClassificationScreen extends StatefulWidget {
  const PlaneClassificationScreen({super.key});

  @override
  State<PlaneClassificationScreen> createState() =>
      _PlaneClassificationScreenState();
}

class _PlaneClassificationScreenState
    extends State<PlaneClassificationScreen> {
  String mode = "Standard";

  @override
  Widget build(BuildContext context) {
    final options = ["Standard", "Enhanced", "High Precision"];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Plane Classification", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            "Controls how MetaZone detects and identifies real-world surfaces.",
            style: AppTextStyles.caption(),
          ),

          const SizedBox(height: 16),

          ...options.map((o) {
            return Card(
              color: AppColors.card,
              child: RadioListTile<String>(
                value: o,
                groupValue: mode,
                onChanged: (v) => setState(() => mode = v!),
                title: Text(o),
                subtitle: Text(
                  o == "Standard"
                      ? "Basic plane detection"
                      : o == "Enhanced"
                      ? "Better wall / floor / table tracking"
                      : "Maximum accuracy for AR objects",
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
