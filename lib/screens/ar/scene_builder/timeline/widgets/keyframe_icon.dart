// File: keyframe_icon.dart
// MetaZone – Timeline Keyframe Icon (Ultra PRO Edition)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class KeyframeIcon extends StatelessWidget {
  final bool selected;

  const KeyframeIcon({super.key, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white.withOpacity(.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected ? Colors.black : AppColors.border.withOpacity(.5),
          width: 1,
        ),
        boxShadow: selected
            ? [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.7),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ]
            : [],
      ),
    );
  }
}
