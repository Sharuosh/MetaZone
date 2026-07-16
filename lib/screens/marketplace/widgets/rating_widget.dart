import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class RatingWidget extends StatelessWidget {
  final double rating; // من 0 لـ 5

  const RatingWidget({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating.round();
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: filled ? AppColors.primary : AppColors.textSoft,
        );
      }),
    );
  }
}
