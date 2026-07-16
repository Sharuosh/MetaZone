// File: lib/screens/ar/portal_editor/widgets/editor_top_bar.dart
// MetaZone – Portal Editor (TOP BAR – FIXED & FULL PRO VERSION)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PortalEditorTopBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onExport;

  /// الآن غير مطلوب منك تمرير onBack — النظام هيولده تلقائياً
  final VoidCallback? onBack;

  /// نفس الكلام بالنسبة لـ Publish — لو مش مبعوتة بنحط Default handler
  final VoidCallback? onPublish;

  final VoidCallback? onSettings;
  final String title;

  const PortalEditorTopBar({
    super.key,
    required this.onSave,
    required this.onExport,
    this.onBack,
    this.onPublish,
    this.onSettings,
    this.title = "Portal Editor",
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 26,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // BACK BUTTON
          _glassButton(
            Icons.arrow_back_ios_new_rounded,
            onBack ?? () => Navigator.of(context).pop(),
          ),

          const SizedBox(width: 12),

          // TITLE
          Text(
            title,
            style: AppTextStyles.title(size: 20),
          ),

          const Spacer(),

          // SAVE BUTTON
          _smallButton(Icons.save_rounded, "Save", onSave),

          const SizedBox(width: 12),

          // EXPORT JSON BUTTON
          _smallButton(Icons.file_download_rounded, "Export", onExport),

          const SizedBox(width: 12),

          // SETTINGS BUTTON (optional)
          if (onSettings != null)
            _glassButton(Icons.tune_rounded, onSettings!),

          const SizedBox(width: 12),

          // PUBLISH BUTTON (Neon)
          _publishButton(
            onPublish ??
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Publish coming soon…")),
                  );
                },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // Basic glass button (Back / Settings)
  // -----------------------------------------------------
  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card.withOpacity(.45),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.25),
              blurRadius: 14,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  // -----------------------------------------------------
  // Small Action Button (Save / Export)
  // -----------------------------------------------------
  Widget _smallButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card.withOpacity(.60),
          border: Border.all(color: AppColors.border.withOpacity(.40)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.body(size: 13)
                    .copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // PUBLISH BUTTON (Neon Button)
  // -----------------------------------------------------
  Widget _publishButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft,
              blurRadius: 24,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_upload_rounded,
                color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              "Publish",
              style: AppTextStyles.body(size: 14)
                  .copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
