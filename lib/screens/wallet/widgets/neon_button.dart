// File: lib/screens/wallet/widgets/neon_button.dart
// MetaZone — Universal Neon Button (Primary Action Button PRO)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;
  final bool fullWidth;

  const NeonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 58,
    this.borderRadius = 18,
    this.fullWidth = true,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.06,
    );

    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _pressCtrl.forward();
  void _onTapUp(_) => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: AppColors.neonGradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primarySoft.withOpacity(.45),
                blurRadius: 26,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: AppTextStyles.title(size: 16)
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
