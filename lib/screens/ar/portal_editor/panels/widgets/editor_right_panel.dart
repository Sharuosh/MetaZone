// File: lib/screens/ar/portal_editor/widgets/editor_right_panel.dart
// MetaZone – Portal Editor (Right Panel Wrapper — FULL PRO)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PortalEditorRightPanel extends StatelessWidget {
  final Widget child;

  const PortalEditorRightPanel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 120,
      bottom: 30,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.55),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border.withOpacity(.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: child,
          ),
        ),
      ),
    );
  }
}
