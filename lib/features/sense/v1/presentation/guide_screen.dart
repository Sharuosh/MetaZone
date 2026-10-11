import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) => const _GuideShell();
}

class _GuideShell extends StatelessWidget {
  const _GuideShell();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB37CFF);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.text),
        title: Text('Guide', style: AppTextStyles.title(size: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.navigation_rounded, color: accent, size: 48),
            const SizedBox(height: 18),
            Text('Guide', style: AppTextStyles.heading(size: 26)),
            const SizedBox(height: 10),
            Text(
              'Guide will combine AI reasoning with AR instructions and step verification while the user performs a real task.',
              style: AppTextStyles.caption(size: 13).copyWith(height: 1.5),
            ),
            const SizedBox(height: 18),
            Text(
              'AI + AR + verification integration point',
              style: AppTextStyles.caption(size: 11, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
