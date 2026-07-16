import 'dart:ui';
import 'package:flutter/material.dart';

class ScanPanel extends StatefulWidget {
  final VoidCallback onClose;

  const ScanPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<ScanPanel> createState() => _ScanPanelState();
}

class _ScanPanelState extends State<ScanPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          color: Colors.black.withOpacity(.15),
          child: Stack(
            children: [

              /// TOP STATUS
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    const Icon(
                      Icons.radar,
                      color: Color(0xff00D4FF),
                      size: 18,
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      "Scan Mode",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ANALYZING TEXT
              Positioned(
                top: 105,
                left: 20,
                child: Text(
                  "Analyzing Environment...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: 13,
                  ),
                ),
              ),

              /// PROGRESS
              Positioned(
                top: 135,
                left: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      return LinearProgressIndicator(
                        value: controller.value,
                        minHeight: 4,
                        backgroundColor:
                        Colors.white.withOpacity(.08),
                        valueColor:
                        const AlwaysStoppedAnimation(
                          Color(0xff00D4FF),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// SCAN TARGET FRAME
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff00D4FF),
                      width: 1.2,
                    ),
                    borderRadius:
                    BorderRadius.circular(28),
                  ),
                ),
              ),

              /// BOTTOM GUIDE
              Positioned(
                bottom: 70,
                left: 0,
                right: 0,
                child: Column(
                  children: [

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(.06),
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Point Camera At Object",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Searching for places, people and objects",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}