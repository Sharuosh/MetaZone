// File: lib/screens/wallet/widgets/section_title.dart
// MetaZone Wallet — Section Title (Clean + Neon Indicator)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Title + Underline glow
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.title(size: 16)),
            const SizedBox(height: 3),

            // Neon mini-line under title
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.35),
                    blurRadius: 8,
                  )
                ],
              ),
            ),
          ],
        ),

        const Spacer(),

        // Optional action text
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: AppTextStyles.caption()
                  .copyWith(color: AppColors.primarySoft),
            ),
          ),
      ],
    );
  }
}
