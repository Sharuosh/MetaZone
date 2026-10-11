import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) => const _ShareShell();
}

class _ShareShell extends StatelessWidget {
  const _ShareShell();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF6FAE);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(color: AppColors.text),
        title: Text('Share', style: AppTextStyles.title(size: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.people_alt_rounded, color: accent, size: 48),
            const SizedBox(height: 18),
            Text('Share', style: AppTextStyles.heading(size: 26)),
            const SizedBox(height: 10),
            Text(
              'Share will become the real-time collaboration layer for the user’s camera view, voice and future spatial annotations.',
              style: AppTextStyles.caption(size: 13).copyWith(height: 1.5),
            ),
            const SizedBox(height: 18),
            Text(
              'Realtime networking + AR annotation integration point',
              style: AppTextStyles.caption(size: 11, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
