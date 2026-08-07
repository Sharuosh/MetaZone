import 'package:flutter/material.dart';

import '../glass/glass_button.dart';
import '../glass/glass_card.dart';
import '../glass/glass_chip.dart';

class AIGenerateCard extends StatelessWidget {
  const AIGenerateCard({
    super.key,

    this.prompt = "",

    this.selectedMode = "Text → 3D",

    this.selectedQuality = "High",

    this.onGenerate,

    this.onHistory,

    this.onChangeMode,

    this.onChangeQuality,
  });

  final String prompt;

  final String selectedMode;

  final String selectedQuality;

  final VoidCallback? onGenerate;

  final VoidCallback? onHistory;

  final ValueChanged<String>? onChangeMode;

  final ValueChanged<String>? onChangeQuality;

  @override
  Widget build(BuildContext context) {
    const modes = [
      "Text → 3D",
      "Image → 3D",
      "Scene AI",
      "World AI",
    ];

    const qualities = [
      "Fast",
      "Balanced",
      "High",
    ];

    return GlassCard(
      variant: GlassCardVariant.hero,

      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),

      padding: const EdgeInsets.all(22),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.auto_awesome,
                color: Color(0xff5B8CFF),
              ),
              SizedBox(width: 10),
              Text(
                "AI Workspace",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Generate complete AR objects, environments and immersive worlds with AI.",
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: .65,
              ),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 22),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: modes
                .map(
                  (e) => GlassChip(
                label: e,
                variant:
                GlassChipVariant.primary,
                selected:
                e == selectedMode,
                onTap: () =>
                    onChangeMode?.call(e),
              ),
            )
                .toList(),
          ),

          const SizedBox(height: 20),

          Container(
            constraints:
            const BoxConstraints(
              minHeight: 140,
            ),
            padding:
            const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                22,
              ),
              color: Colors.white
                  .withValues(alpha: .05),
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: .08),
              ),
            ),
            child: Text(
              prompt.isEmpty
                  ? "Describe anything...\n\nExample:\nA futuristic floating cyberpunk city with holographic advertisements and flying vehicles."
                  : prompt,
              style: TextStyle(
                color: prompt.isEmpty
                    ? Colors.white
                    .withValues(
                  alpha: .45,
                )
                    : Colors.white,
                height: 1.6,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            "Render Quality",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            children: qualities
                .map(
                  (e) => GlassChip(
                label: e,
                selected:
                e == selectedQuality,
                variant:
                GlassChipVariant.success,
                onTap: () =>
                    onChangeQuality
                        ?.call(e),
              ),
            )
                .toList(),
          ),

          const SizedBox(height: 22),

          const Text(
            "Popular Ideas",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              GlassChip(
                label: "Cyberpunk City",
              ),
              GlassChip(
                label: "Fantasy Forest",
              ),
              GlassChip(
                label: "Mars Base",
              ),
              GlassChip(
                label: "Luxury House",
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: GlassButton(
                  hero: true,
                  icon: Icons.bolt,
                  text: "Generate",
                  onPressed: onGenerate,
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(
                width: 60,
                child: GlassButton(
                  variant:
                  GlassButtonVariant.secondary,
                  icon: Icons.history,
                  text: "",
                  onPressed: onHistory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}