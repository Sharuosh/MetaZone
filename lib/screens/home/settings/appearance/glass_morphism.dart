import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class GlassMorphismScreen extends StatefulWidget {
  const GlassMorphismScreen({super.key});

  @override
  State<GlassMorphismScreen> createState() => _GlassMorphismScreenState();
}

class _GlassMorphismScreenState extends State<GlassMorphismScreen> {
  double _intensity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Glass Morphism"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Glass Blur Intensity", style: AppTextStyles.title(size: 16)),
            const SizedBox(height: 12),

            Slider(
              value: _intensity,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _intensity.toStringAsFixed(2),
              onChanged: (v) => setState(() => _intensity = v),
            ),

            const SizedBox(height: 15),
            Text("Preview", style: AppTextStyles.title()),

            const SizedBox(height: 10),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.4 + _intensity * 0.4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.primary.withOpacity(_intensity * 0.6)),
              ),
              alignment: Alignment.center,
              child: Text(
                "Glass Preview",
                style: AppTextStyles.body(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
