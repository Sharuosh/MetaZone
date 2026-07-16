// File: lib/screens/ar/object_editor/widgets/editor_top_bar.dart
// MetaZone — AR Object Editor (Top Bar)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EditorTopBar extends StatelessWidget {
  final String objectName;
  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final VoidCallback? onPublish;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const EditorTopBar({
    super.key,
    required this.objectName,
    this.onBack,
    this.onSave,
    this.onPublish,
    this.onUndo,
    this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 26,
      left: 14,
      right: 14,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.15),
              blurRadius: 20,
            )
          ],
        ),
        child: Row(
          children: [
            // BACK BUTTON
            _glassIcon(
              icon: Icons.arrow_back_ios_new,
              onTap: onBack ?? () => Navigator.pop(context),
            ),

            const SizedBox(width: 14),

            // TITLE
            Expanded(
              child: Text(
                objectName,
                style: AppTextStyles.title(size: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // UNDO
            _glassIcon(
              icon: Icons.undo,
              onTap: onUndo,
            ),

            const SizedBox(width: 10),

            // REDO
            _glassIcon(
              icon: Icons.redo,
              onTap: onRedo,
            ),

            const SizedBox(width: 14),

            // SAVE BUTTON
            _neonButton(
              icon: Icons.save,
              label: "Save",
              onTap: onSave,
            ),

            const SizedBox(width: 10),

            // PUBLISH BUTTON
            _neonButton(
              icon: Icons.upload_rounded,
              label: "Publish",
              onTap: onPublish,
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // GLASS ICON BUTTON
  // =============================================================
  Widget _glassIcon({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // =============================================================
  // NEON BUTTON
  // =============================================================
  Widget _neonButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.8),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body(size: 14).copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
