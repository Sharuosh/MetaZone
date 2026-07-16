import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TextureSharpnessScreen extends StatefulWidget {
  const TextureSharpnessScreen({super.key});

  @override
  State<TextureSharpnessScreen> createState() => _TextureSharpnessScreenState();
}

class _TextureSharpnessScreenState extends State<TextureSharpnessScreen> {
  double _sharpness = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Texture Sharpness"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sharpness Level", style: AppTextStyles.title()),
            const SizedBox(height: 14),

            Slider(
              value: _sharpness,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: _sharpness.toStringAsFixed(2),
              onChanged: (v) => setState(() => _sharpness = v),
            ),

            const SizedBox(height: 20),

            Text("Preview", style: AppTextStyles.title()),
            const SizedBox(height: 10),

            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.border.withOpacity(_sharpness / 2)),
              ),
              child: Text(
                "UI Sharpness Preview",
                style: AppTextStyles.body()
                    .copyWith(fontWeight: _sharpness > 1.2
                    ? FontWeight.w700
                    : FontWeight.w400),
              ),
            )
          ],
        ),
      ),
    );
  }
}
