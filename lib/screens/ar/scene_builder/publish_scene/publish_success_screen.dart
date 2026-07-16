// File: publish_success_screen.dart
// MetaZone — Publish Success (Ultra PRO 2025)
// Shown after successfully publishing a scene.

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../models/publish_scene_payload.dart';

class PublishSuccessScreen extends StatefulWidget {
  final PublishScenePayload payload;

  const PublishSuccessScreen({super.key, required this.payload});

  @override
  State<PublishSuccessScreen> createState() => _PublishSuccessScreenState();
}

class _PublishSuccessScreenState extends State<PublishSuccessScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.75,
      upperBound: 1.0,
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.payload;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // =======================================================
                // SUCCESS ANIMATION
                // =======================================================
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _scaleCtrl,
                    curve: Curves.elasticOut,
                  ),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: AppColors.neonGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primarySoft.withOpacity(.5),
                          blurRadius: 30,
                          spreadRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 70, color: Colors.black),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Scene Published!",
                  style: AppTextStyles.heading(size: 26),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  "Your AR scene is now live for the world to explore.",
                  style: AppTextStyles.caption(size: 14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // =======================================================
                // SCENE PREVIEW
                // =======================================================
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(.25),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border.withOpacity(.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: scene.coverUrl.isNotEmpty
                            ? Image.network(scene.coverUrl,
                            height: 140, width: double.infinity,
                            fit: BoxFit.cover)
                            : Container(
                          height: 140,
                          color: Colors.white12,
                          child: const Icon(Icons.image, size: 50),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(scene.title,
                          style: AppTextStyles.title(size: 16)),
                      const SizedBox(height: 4),

                      Text("Category: ${scene.category}",
                          style: AppTextStyles.caption(size: 12)),
                    ],
                  ),
                ),

                const Spacer(),

                // =======================================================
                // BUTTONS
                // =======================================================
                _buttons(),

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // Bottom CTA Buttons
  // =============================================================
  Widget _buttons() {
    return Column(
      children: [
        // View Scene
        GestureDetector(
          onTap: () {
            // TODO: open scene details screen
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "View Scene",
                style: AppTextStyles.title(size: 16)
                    .copyWith(color: Colors.black),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Share Button
        GestureDetector(
          onTap: () {
            // TODO: implement share
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(.35)),
            ),
            child: Center(
              child: Text(
                "Share",
                style: AppTextStyles.body(size: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Back to Home
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Back to Builder",
            style: AppTextStyles.caption(size: 13)
                .copyWith(color: AppColors.primarySoft),
          ),
        ),
      ],
    );
  }
}
