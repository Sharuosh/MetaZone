// File: lib/screens/ar/scene_builder/publish_scene/widgets/publish_error_card.dart
// MetaZone — Publish Error Card (PRO 2025)
// Stylish error block with neon edges + retry button

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PublishErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onDetails;

  const PublishErrorCard({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.redAccent.withOpacity(.35),
          width: 1.4,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(.15),
            AppColors.card.withOpacity(.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.title(size: 16)
                      .copyWith(color: Colors.redAccent),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Description text
          Text(
            message,
            style: AppTextStyles.caption(size: 13)
                .copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              // Retry Button
              Expanded(
                child: GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.neonGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Retry",
                        style: AppTextStyles.title(size: 14)
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Optional Details Button
              if (onDetails != null)
                GestureDetector(
                  onTap: onDetails,
                  child: Container(
                    height: 46,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.border.withOpacity(.4)),
                    ),
                    child: Center(
                      child: Text(
                        "Details",
                        style: AppTextStyles.caption(size: 13),
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}
