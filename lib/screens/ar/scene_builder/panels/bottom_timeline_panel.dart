// File: lib/screens/ar/scene_builder/panels/bottom_timeline_panel.dart
// MetaZone – AR Scene Builder: Timeline Panel (Design Only – Ultra PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class BottomTimelinePanel extends StatefulWidget {
  const BottomTimelinePanel({super.key});

  @override
  State<BottomTimelinePanel> createState() => _BottomTimelinePanelState();
}

class _BottomTimelinePanelState extends State<BottomTimelinePanel>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeCtrl,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.22),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: AppColors.border.withOpacity(.3)),
        ),
        child: Column(
          children: [
            _topControls(),
            const SizedBox(height: 6),
            Expanded(child: _timelineTracks()),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TOP CONTROL BAR
  // =============================================================
  Widget _topControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          // PLAY BUTTON
          _circleBtn(Icons.play_arrow_rounded),

          const SizedBox(width: 10),

          // LOOP
          Icon(Icons.loop_rounded, color: AppColors.textSoft, size: 22),

          const SizedBox(width: 16),

          // TIME INDICATOR
          Text("0.0s / 3.0s",
              style: AppTextStyles.caption(size: 12)
                  .copyWith(color: AppColors.textSoft)),

          const Spacer(),

          // ZOOM CONTROLS
          _circleBtn(Icons.zoom_in),
          const SizedBox(width: 10),
          _circleBtn(Icons.zoom_out),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.15),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Icon(icon, color: AppColors.textSoft, size: 20),
    );
  }

  // =============================================================
  // TIMELINE TRACKS
  // =============================================================
  Widget _timelineTracks() {
    final List<Map<String, dynamic>> tracks = [
      {"name": "Neon Cube", "keys": [0.2, 0.7]},
      {"name": "Portal Ring", "keys": [0.1, 0.5, 0.9]},
      {"name": "FX Spark", "keys": [0.4]},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: tracks.length,
      itemBuilder: (_, i) => _trackItem(tracks[i]),
    );
  }

  // =============================================================
  // SINGLE TRACK ROW
  // =============================================================
  Widget _trackItem(Map<String, dynamic> track) {
    final List<double> keys = List<double>.from(track["keys"]);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // TRACK LABEL
          SizedBox(
            width: 90,
            child: Text(
              track["name"],
              style: AppTextStyles.caption(size: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 12),

          // TRACK BAR + KEYFRAMES
          Expanded(
            child: Container(
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border.withOpacity(.25)),
              ),
              child: Stack(
                children: [
                  // KEYFRAMES
                  ...keys.map((k) => _keyframeDot(k)).toList(),

                  // PLAYHEAD (fixed at 0.3 for design)
                  _playhead(0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // KEYFRAME DOT
  // =============================================================
  Widget _keyframeDot(double position) {
    return Positioned(
      left: position * 240, // proportional placement
      top: 4,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // PLAYHEAD (Vertical Neon Line)
  // =============================================================
  Widget _playhead(double pos) {
    return Positioned(
      left: pos * 240,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
