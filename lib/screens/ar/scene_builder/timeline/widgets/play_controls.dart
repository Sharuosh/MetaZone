// File: play_controls.dart
// MetaZone – Timeline Play Controls (Ultra PRO Edition)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PlayControls extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const PlayControls({
    super.key,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.play_arrow_rounded, onPlay),
          const SizedBox(width: 8),
          _btn(Icons.pause_rounded, onPause),
          const SizedBox(width: 8),
          _btn(Icons.stop_rounded, onStop),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }
}
