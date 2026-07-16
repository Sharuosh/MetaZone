// File: timeline_track.dart
// MetaZone – Timeline Track (Ultra PRO Edition)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'widgets/keyframe_icon.dart';

class TimelineTrack extends StatelessWidget {
  final String label;
  final List<int> keyframes; // frame positions
  final int selectedFrame;
  final ValueChanged<int> onFrameSelected;

  const TimelineTrack({
    super.key,
    required this.label,
    required this.keyframes,
    required this.selectedFrame,
    required this.onFrameSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Track label
          SizedBox(
            width: 90,
            child: Text(label,
                style: AppTextStyles.caption(size: 12).copyWith(
                  color: AppColors.textSoft,
                )),
          ),

          // Timeline ruler
          Expanded(
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border.withOpacity(.3)),
              ),
              child: Stack(
                children: [
                  // Keyframes
                  ...keyframes.map((frame) {
                    return Positioned(
                      left: frame.toDouble(),
                      top: 9,
                      child: GestureDetector(
                        onTap: () => onFrameSelected(frame),
                        child: KeyframeIcon(
                          selected: selectedFrame == frame,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
