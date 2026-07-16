import 'dart:ui';
import 'package:flutter/material.dart';

class CameraBottomControls extends StatelessWidget {
  final int mode;
  final VoidCallback onCapture;

  const CameraBottomControls({
    super.key,
    required this.mode,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 28,
      left: 20,
      right: 20,
      child: Column(
        children: [
          /// ZOOM BAR
          Container(
            width: 220,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.55),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(.06),
              ),
            ),
            child: const Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: [
                _ZoomItem("0.5"),
                _ZoomItem("1x", selected: true),
                _ZoomItem("2"),
                _ZoomItem("3"),
              ],
            ),
          ),
          const Text(
            "Capture AR Moment",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),
          const SizedBox(height: 26),

          /// CAPTURE BUTTON ONLY
          GestureDetector(
            onTap: onCapture,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(.20),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomItem extends StatelessWidget {
  final String value;
  final bool selected;

  const _ZoomItem(
      this.value, {
        this.selected = false,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? const Color(0xff00D4FF)
            .withOpacity(.15)
            : Colors.transparent,
      ),
      child: Text(
        value,
        style: TextStyle(
          color: selected
              ? const Color(0xff00D4FF)
              : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}