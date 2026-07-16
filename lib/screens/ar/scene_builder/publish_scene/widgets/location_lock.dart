// File: location_lock.dart
// MetaZone — Location Lock Selector (Ultra PRO 2025)
// FINAL VERSION — compatible with PublishSceneScreen

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class LocationLock extends StatefulWidget {
  final bool enabled;
  final double radius;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onRadiusChange;

  const LocationLock({
    super.key,
    required this.enabled,
    required this.radius,
    required this.onToggle,
    required this.onRadiusChange,
  });

  @override
  State<LocationLock> createState() => _LocationLockState();
}

class _LocationLockState extends State<LocationLock> {
  late double radius;

  @override
  void initState() {
    super.initState();
    radius = widget.radius;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Lock Scene to Location",
                style: AppTextStyles.title(size: 14)),
            Switch(
              value: widget.enabled,
              activeColor: AppColors.primary,
              onChanged: widget.onToggle,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // When disabled → Show info box
        if (!widget.enabled)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(.3)),
            ),
            child: Text(
              "Enable to lock the AR scene to a real GPS location.",
              style: AppTextStyles.caption(size: 12)
                  .copyWith(color: AppColors.textSoft),
            ),
          ),

        // When enabled → Show full widget
        if (widget.enabled) ...[
          _miniMapPreview(),
          const SizedBox(height: 14),

          Text("Visibility Radius", style: AppTextStyles.title(size: 14)),
          const SizedBox(height: 10),

          _radiusSlider(),

          const SizedBox(height: 6),
          Text(
            "${radius.toStringAsFixed(0)} meters",
            style: AppTextStyles.caption(size: 12)
                .copyWith(color: AppColors.primarySoft),
          ),
        ],
      ],
    );
  }

  // =============================================================
  // STATIC MAP PREVIEW
  // =============================================================
  Widget _miniMapPreview() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location picker coming soon")),
        );
      },
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
          image: const DecorationImage(
            image: NetworkImage(
              "https://maps.googleapis.com/maps/api/staticmap?"
                  "center=30.0444,31.2357&zoom=15&size=600x300&key=FAKE_KEY",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: Icon(Icons.location_on,
                  size: 44, color: AppColors.primary),
            ),

            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Change Location",
                  style: AppTextStyles.caption(size: 12)
                      .copyWith(color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // =============================================================
  // RADIUS SLIDER
  // =============================================================
  Widget _radiusSlider() {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border.withOpacity(.4),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primarySoft.withOpacity(.3),
        trackHeight: 4,
      ),
      child: Slider(
        value: radius,
        min: 10,
        max: 500,
        divisions: 20,
        label: "${radius.toStringAsFixed(0)}m",
        onChanged: (v) {
          setState(() => radius = v);
          widget.onRadiusChange(v);
        },
      ),
    );
  }
}
