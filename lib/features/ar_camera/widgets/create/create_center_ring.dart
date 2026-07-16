import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CreateCenterRing extends StatefulWidget {
  const CreateCenterRing({super.key});

  @override
  State<CreateCenterRing> createState() => _CreateCenterRingState();
}

class _CreateCenterRingState extends State<CreateCenterRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _controller.value * pi * 2,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: _RingPainter(),
                ),
              ),

              /// OUTER GLASS
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(.05),
                          Colors.white.withOpacity(.01),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xff00D4FF,
                          ).withOpacity(.10),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// INNER CORE
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.02),
                  border: Border.all(
                    color: Colors.white.withOpacity(.05),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 4,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final outerRing = Paint()
      ..color = const Color(0xff00D4FF).withOpacity(.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final innerRing = Paint()
      ..color = Colors.white.withOpacity(.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 28, outerRing);
    canvas.drawCircle(center, 26, innerRing);

    for (int i = 0; i < 6; i++) {
      final angle = (pi * 2 / 6) * i;

      final point = Offset(
        center.dx + cos(angle) * 30,
        center.dy + sin(angle) * 30,
      );

      canvas.drawCircle(
        point,
        2,
        Paint()
          ..color = const Color(0xff00D4FF)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            2,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}