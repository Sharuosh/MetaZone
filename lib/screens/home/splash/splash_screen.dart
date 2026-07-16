import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoPulse;
  late AnimationController _ringRotation;
  late AnimationController _fadeText;

  final Random _rnd = Random();
  final List<Offset> _stars = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 55; i++) {
        _stars.add(
          Offset(
            _rnd.nextDouble() * size.width,
            _rnd.nextDouble() * size.height,
          ),
        );
      }
      setState(() {});
    });

    _logoPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _ringRotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _fadeText = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    });
  }

  @override
  void dispose() {
    _logoPulse.dispose();
    _ringRotation.dispose();
    _fadeText.dispose();
    super.dispose();
  }

  List<Widget> _buildStars() {
    return List.generate(
      _stars.length,
          (i) => Positioned(
        top: _stars[i].dy,
        left: _stars[i].dx,
        child: AnimatedOpacity(
          opacity: _rnd.nextBool() ? 1 : .15,
          duration: Duration(milliseconds: 800 + _rnd.nextInt(1400)),
          child: Container(
            width: 1.2 + _rnd.nextDouble() * 2,
            height: 1.2 + _rnd.nextDouble() * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glow = Tween<double>(begin: 0.4, end: 1.0).animate(_logoPulse);
    final scale = Tween<double>(begin: .9, end: 1.05).animate(_logoPulse);

    return Scaffold(
      body: Stack(
        children: [
          /// أسود قاتم – بدون أي إزعاج بصري
          Container(color: const Color(0xFF020202)),

          /// نجوم دقيقة جداً
          ..._buildStars(),

          /// ضوء أسود بارد خفيف من الأسفل
          Positioned(
            bottom: -160,
            right: -140,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(.08),
              ),
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// حلقة AR داكنة راقية
                    RotationTransition(
                      turns: _ringRotation,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.white.withOpacity(.15),
                              Colors.transparent,
                              Colors.cyanAccent.withOpacity(.2),
                              Colors.transparent,
                            ],
                          ),
                        ),

                        /// الشعار النابض
                        child: ScaleTransition(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(.03),
                              border: Border.all(
                                color: Colors.cyanAccent.withOpacity(.25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent
                                      .withOpacity(glow.value * .7),
                                  blurRadius: 50,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/logo.png",
                              height: 140,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    /// اسم MetaZone بشكل قوي جداً
                    FadeTransition(
                      opacity: _fadeText,
                      child: Text(
                        "Meta Zone",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.cyanAccent.withOpacity(.7),
                              blurRadius: 25,
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    FadeTransition(
                      opacity: _fadeText,
                      child: const Text(
                        "AR Platform",
                        style: TextStyle(
                          color: Colors.white54,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    FadeTransition(
                      opacity: _fadeText,
                      child: const CircularProgressIndicator(
                        color: Colors.cyanAccent,
                        strokeWidth: 2.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
