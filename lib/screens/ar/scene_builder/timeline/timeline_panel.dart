// File: timeline_panel.dart
// MetaZone – Timeline Panel (Ultra PRO Edition 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'timeline_track.dart';
import 'widgets/play_controls.dart';

class TimelinePanel extends StatefulWidget {
  const TimelinePanel({super.key});

  @override
  State<TimelinePanel> createState() => _TimelinePanelState();
}

class _TimelinePanelState extends State<TimelinePanel> {
  int selectedFrame = 0;

  // Fake timeline data for UI only
  final List<int> positionKeyframes = [10, 60, 120, 200];
  final List<int> rotationKeyframes = [40, 140, 220];
  final List<int> scaleKeyframes = [20, 180];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _header(),
          const SizedBox(height: 14),
          _timelineBody(),
          const SizedBox(height: 14),
          _controls(),
        ],
      ),
    );
  }

  // =============================================================
  // Header Text
  // =============================================================
  Widget _header() {
    return Row(
      children: [
        Text("Timeline", style: AppTextStyles.title(size: 18)),
        const Spacer(),
        Text(
          "Frame: $selectedFrame",
          style: AppTextStyles.caption(size: 12)
              .copyWith(color: AppColors.textSoft),
        ),
      ],
    );
  }

  // =============================================================
  // Timeline Tracks + Scrollable area + Frame cursor
  // =============================================================
  Widget _timelineBody() {
    return Expanded(
      child: Stack(
        children: [
          // Scrollable area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 600, // length of timeline canvas
              child: Column(
                children: [
                  TimelineTrack(
                    label: "Position",
                    keyframes: positionKeyframes,
                    selectedFrame: selectedFrame,
                    onFrameSelected: (f) {
                      setState(() => selectedFrame = f);
                    },
                  ),
                  TimelineTrack(
                    label: "Rotation",
                    keyframes: rotationKeyframes,
                    selectedFrame: selectedFrame,
                    onFrameSelected: (f) {
                      setState(() => selectedFrame = f);
                    },
                  ),
                  TimelineTrack(
                    label: "Scale",
                    keyframes: scaleKeyframes,
                    selectedFrame: selectedFrame,
                    onFrameSelected: (f) {
                      setState(() => selectedFrame = f);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Frame cursor (neon line)
          Positioned(
            left: selectedFrame.toDouble(),
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.7),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // Bottom controls
  // Play / Pause / Stop
  // =============================================================
  Widget _controls() {
    return PlayControls(
      onPlay: () {},
      onPause: () {},
      onStop: () {
        setState(() => selectedFrame = 0);
      },
    );
  }
}
