// File: publish_progress_modal.dart
// MetaZone – Publish Progress Modal (Ultra PRO 2025)
// Animated Upload → Processing → Finalizing visual flow.

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PublishProgressModal extends StatefulWidget {
  final double progress;        // 0 → 1.0
  final String statusText;      // "Uploading...", "Processing...", etc.
  final VoidCallback? onCancel; // Optional cancel action

  const PublishProgressModal({
    super.key,
    required this.progress,
    required this.statusText,
    this.onCancel,
  });

  @override
  State<PublishProgressModal> createState() => _PublishProgressModalState();
}

class _PublishProgressModalState extends State<PublishProgressModal>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.85,
      upperBound: 1.15,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(.65),
          ),
        ),

        // Centered Modal
        Center(
          child: ScaleTransition(
            scale: _pulseCtrl,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withOpacity(.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.4),
                    blurRadius: 22,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Progress
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: widget.progress,
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          backgroundColor:
                          AppColors.textSoft.withOpacity(.2),
                        ),
                        Center(
                          child: Text(
                            "${(widget.progress * 100).toInt()}%",
                            style: AppTextStyles.title(size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status Text
                  Text(
                    widget.statusText,
                    style: AppTextStyles.body(size: 14)
                        .copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  if (widget.onCancel != null)
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.border.withOpacity(.4)),
                        ),
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(size: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
