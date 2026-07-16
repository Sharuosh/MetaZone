// File: lib/screens/ar/scene_builder/widgets/property_slider.dart
// MetaZone – Property Slider (Neon Edition 2025)
// Used across material, lighting, physics & animation panels

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PropertySlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final String? label;

  const PropertySlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.label,
  });

  @override
  State<PropertySlider> createState() => _PropertySliderState();
}

class _PropertySliderState extends State<PropertySlider> {
  late double currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: AppTextStyles.caption(size: 12),
            ),
          ),

        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            inactiveTrackColor: Colors.white10,
            activeTrackColor: AppColors.primarySoft,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primarySoft.withOpacity(.3),
            valueIndicatorColor: AppColors.primary,
            thumbShape: _NeonThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: currentValue,
            min: widget.min,
            max: widget.max,
            onChanged: (v) {
              setState(() => currentValue = v);
              if (widget.onChanged != null) widget.onChanged!(v);
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================
// THUMB SHAPE (NEON GLOW)
// =============================================================
class _NeonThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double? textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.primarySoft.withOpacity(.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, 10, glowPaint);

    // Inner thumb
    final thumbPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, thumbPaint);
  }
}
