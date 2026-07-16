// File: draft_save_banner.dart
// MetaZone – Draft Auto-Save Banner (Ultra PRO 2025)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class DraftSaveBanner extends StatefulWidget {
  final String status; // "saving", "saved", "error"

  const DraftSaveBanner({super.key, required this.status});

  @override
  State<DraftSaveBanner> createState() => _DraftSaveBannerState();
}

class _DraftSaveBannerState extends State<DraftSaveBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    // Auto hide after timeout
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _slideCtrl.reverse();
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.status) {
      case "saving":
        return Icons.sync;
      case "saved":
        return Icons.check_circle;
      default:
        return Icons.error_outline;
    }
  }

  Color _getColor() {
    switch (widget.status) {
      case "saving":
        return AppColors.primarySoft;
      case "saved":
        return Colors.greenAccent;
      default:
        return Colors.redAccent;
    }
  }

  String _getMessage() {
    switch (widget.status) {
      case "saving":
        return "Saving draft...";
      case "saved":
        return "Draft saved!";
      default:
        return "Failed to save draft.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.38),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
          boxShadow: [
            BoxShadow(
              color: _getColor().withOpacity(.25),
              blurRadius: 14,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(_getIcon(), color: _getColor(), size: 22),
            const SizedBox(width: 12),
            Text(
              _getMessage(),
              style: AppTextStyles.body(size: 14)
                  .copyWith(color: Colors.white),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
