// File: lib/screens/ar/scene_builder/widgets/neon_icon_button.dart
// MetaZone – Neon Icon Button (Ultra PRO 2025)
// Global neon button used across Scene Builder tools & editors

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;
  final bool active;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 42,
    this.active = false,
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _tapCtrl;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.12,
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapCtrl.forward(),
      onTapUp: (_) {
        _tapCtrl.reverse();
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => _tapCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _tapCtrl,
        builder: (_, child) {
          double scale = 1 - _tapCtrl.value;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.active ? AppColors.neonGradient : null,
                color: widget.active
                    ? null
                    : AppColors.card.withOpacity(.22),
                border: Border.all(
                  color: widget.active
                      ? Colors.transparent
                      : AppColors.border.withOpacity(.35),
                ),
                boxShadow: widget.active
                    ? [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.6),
                    blurRadius: 18,
                    spreadRadius: 1,
                  )
                ]
                    : [],
              ),
              child: Icon(
                widget.icon,
                color: widget.active ? Colors.black : AppColors.textSoft,
                size: widget.size * 0.52,
              ),
            ),
          );
        },
      ),
    );
  }
}
