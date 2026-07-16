// lib/screens/home/widgets/ar_panel/ar_panel_toggle.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARPanelToggle extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onPressed;

  const ARPanelToggle({required this.isOpen, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(isOpen ? 1.0 : 0.92),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.16), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar, color: Colors.black),
              const SizedBox(width: 10),
              Text(isOpen ? "Close AR Panel" : "Open AR Tools", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
