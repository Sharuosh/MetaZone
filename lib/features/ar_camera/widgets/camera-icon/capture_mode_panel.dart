import 'dart:ui';
import 'package:flutter/material.dart';

class CaptureModePanel extends StatelessWidget {
  final VoidCallback? onClose;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CaptureModePanel({
    super.key,
    this.onClose,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 95,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.35),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(.08),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),

                    const Text(
                      "Capture Mode",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.08),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _modeCard(
                        index: 0,
                        title: "Photo",
                        icon: Icons.camera_alt_outlined,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _modeCard(
                        index: 1,
                        title: "Video",
                        icon: Icons.videocam_outlined,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _modeCard(
                        index: 2,
                        title: "Spatial AR",
                        icon: Icons.view_in_ar,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeCard({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected
              ? const Color(0xff007AFF).withOpacity(.15)
              : Colors.white.withOpacity(.04),
          border: Border.all(
            color: selected
                ? const Color(0xff00D4FF)
                : Colors.white.withOpacity(.08),
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: selected
                  ? const Color(0xff00D4FF)
                  : Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}