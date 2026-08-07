import 'package:flutter/material.dart';

import '../glass/glass_button.dart';
import '../glass/glass_card.dart';
import '../glass/glass_chip.dart';
import '../glass/glass_container.dart';

class AIBanner extends StatefulWidget {
  const AIBanner({
    super.key,

    this.online = true,

    this.models = "12 Models",

    this.generations = "28K+",

    this.speed = "<5 sec",

    this.activeUsers = "4.8K",

    this.aiVersion = "AI v2.0",

    this.onGenerate,

    this.onExplore,
  });

  final bool online;

  final String models;

  final String generations;

  final String speed;

  final String activeUsers;

  final String aiVersion;

  final VoidCallback? onGenerate;

  final VoidCallback? onExplore;

  @override
  State<AIBanner> createState() =>
      _AIBannerState();
}

class _AIBannerState
    extends State<AIBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff5B8CFF);

    return AnimatedBuilder(
      animation: controller,

      builder: (_, __) {
        final glow =
            30 + controller.value * 25;

        return GlassCard(
          margin:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          padding:
          const EdgeInsets.all(26),

          variant:
          GlassCardVariant.hero,

          level: GlassLevel.hero,

          accentColor: accent,

          child: Row(
            children: [
              Expanded(
                flex: 3,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .auto_awesome,
                          color: accent,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        const Text(
                          "MetaZone AI",

                          style: TextStyle(
                            color:
                            Colors.white,
                            fontSize: 26,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        _StatusChip(
                          online:
                          widget.online,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      "Generate complete AR objects, immersive scenes, interactive worlds and spatial experiences powered by next-generation AI.",

                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: .68,
                        ),
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children: const [
                        GlassChip(
                          label:
                          "Text → 3D",
                          icon:
                          Icons
                              .text_fields,
                        ),
                        GlassChip(
                          label:
                          "Image → 3D",
                          icon:
                          Icons.image,
                        ),
                        GlassChip(
                          label:
                          "Voice AI",
                          icon:
                          Icons.mic,
                        ),
                        GlassChip(
                          label:
                          "Scene AI",
                          icon:
                          Icons
                              .landscape,
                        ),
                        GlassChip(
                          label:
                          "World AI",
                          icon:
                          Icons.public,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Row(
                      children: [
                        _Stat(
                          widget.models,
                          "Models",
                        ),

                        const SizedBox(
                          width: 28,
                        ),

                        _Stat(
                          widget
                              .generations,
                          "Generated",
                        ),

                        const SizedBox(
                          width: 28,
                        ),

                        _Stat(
                          widget.speed,
                          "Average",
                        ),

                        const SizedBox(
                          width: 28,
                        ),

                        _Stat(
                          widget
                              .activeUsers,
                          "Online",
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Row(
                      children: [
                        SizedBox(
                          width: 190,

                          child: GlassButton(
                            hero: true,

                            icon: Icons.bolt,

                            text:
                            "Generate",

                            onPressed:
                            widget
                                .onGenerate,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        SizedBox(
                          width: 170,

                          child: GlassButton(
                            variant:
                            GlassButtonVariant
                                .secondary,

                            icon: Icons
                                .explore,

                            text:
                            "Explore",

                            onPressed:
                            widget
                                .onExplore,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 30),

              Expanded(
                flex: 2,

                child: Center(
                  child: Container(
                    width: 240,
                    height: 240,

                    decoration:
                    BoxDecoration(
                      shape:
                      BoxShape.circle,

                      gradient:
                      const LinearGradient(
                        colors: [
                          Color(
                              0xff5B8CFF),
                          Color(
                              0xff845CFF),
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(
                              0xff5B8CFF)
                              .withValues(
                            alpha: .45,
                          ),
                          blurRadius: glow,
                          spreadRadius: 8,
                        ),
                      ],
                    ),

                    child: Center(
                      child: Column(
                        mainAxisSize:
                        MainAxisSize
                            .min,

                        children: [
                          const Icon(
                            Icons
                                .auto_awesome,

                            color:
                            Colors.white,

                            size: 78,
                          ),

                          const SizedBox(
                              height: 10),

                          Text(
                            widget.aiVersion,

                            style:
                            const TextStyle(
                              color: Colors
                                  .white,

                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.online,
  });

  final bool online;

  @override
  Widget build(BuildContext context) {
    final color =
    online ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: color.withValues(alpha: .35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            online ? "ONLINE" : "OFFLINE",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      this.value,
      this.label,
      );

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: .60,
            ),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CapabilityIndicator
    extends StatelessWidget {
  const _CapabilityIndicator({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(
                  alpha: .70,
                ),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              "${(value * 100).round()}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius:
          BorderRadius.circular(30),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            color: color,
            backgroundColor:
            Colors.white.withValues(
              alpha: .08,
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .55),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  const _GlassDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(
        alpha: .08,
      ),
    );
  }
}