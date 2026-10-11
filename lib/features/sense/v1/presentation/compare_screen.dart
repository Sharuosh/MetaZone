import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) => const _Placeholder(
    title: 'Compare',
    icon: Icons.compare_arrows_rounded,
    accent: Color(0xFFFFB45E),
    description:
    'Compare two or more real-world objects after Vision identifies them and the user selects what should be compared.',
    integration: 'Vision + object selection + AI comparison integration point',
  );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.title,
    required this.icon,
    required this.accent,
    required this.description,
    required this.integration,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String description;
  final String integration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.text),
        title: Text(title, style: AppTextStyles.title(size: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 48),
            const SizedBox(height: 18),
            Text(title, style: AppTextStyles.heading(size: 26)),
            const SizedBox(height: 10),
            Text(description, style: AppTextStyles.caption(size: 13)),
            const SizedBox(height: 18),
            Text(integration, style: AppTextStyles.caption(size: 11, color: accent)),
          ],
        ),
      ),
    );
  }
}
