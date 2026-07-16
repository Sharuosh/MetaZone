// File: lib/screens/ar/scene_builder/widgets/section_header.dart
// MetaZone – Section Header (Neon Line + Title) – Ultra PRO Edition 2025

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.fontSize = 15,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          // Neon Line
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Title
          Text(
            title,
            style: AppTextStyles.title(size: fontSize)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
