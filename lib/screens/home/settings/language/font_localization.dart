import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class FontLocalizationScreen extends StatefulWidget {
  const FontLocalizationScreen({super.key});

  @override
  State<FontLocalizationScreen> createState() => _FontLocalizationScreenState();
}

class _FontLocalizationScreenState extends State<FontLocalizationScreen> {
  double _fontSize = 1.0;
  String _fontFamily = "Default";

  final fonts = [
    "Default",
    "Cairo",
    "Roboto",
    "Poppins",
    "Tajawal",
    "Noto Sans",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Font & Localization"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Font Family", style: AppTextStyles.title()),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<String>(
              value: _fontFamily,
              underline: const SizedBox(),
              dropdownColor: AppColors.card,
              items: fonts
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => _fontFamily = v!),
            ),
          ),

          const SizedBox(height: 30),
          Text("Font Scale", style: AppTextStyles.title()),
          const SizedBox(height: 12),

          Slider(
            value: _fontSize,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: _fontSize.toStringAsFixed(2),
            onChanged: (v) {
              setState(() => _fontSize = v);
            },
          ),

          const SizedBox(height: 20),

          Text(
            "Preview Text\nنص تجريبي",
            style: AppTextStyles.body().copyWith(fontSize: 16 * _fontSize),
          ),
        ],
      ),
    );
  }
}
