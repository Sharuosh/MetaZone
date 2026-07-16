import 'package:flutter/material.dart';

class AROverlay extends StatelessWidget {
  final Animation<double> animation;

  const AROverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return IgnorePointer(
          ignoring: animation.value == 0,
          child: Opacity(
            opacity: animation.value * 0.45,
            child: Container(color: Colors.black),
          ),
        );
      },
    );
  }
}
