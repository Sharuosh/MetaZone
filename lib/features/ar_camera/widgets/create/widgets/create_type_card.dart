import 'package:flutter/material.dart';

import '../glass/glass_card.dart';
import '../glass/glass_container.dart';
import '../models/create_type.dart';

class CreateTypeCard extends StatefulWidget {
  const CreateTypeCard({
    super.key,
    required this.type,
    this.selected = false,
    this.onTap,
  });

  final CreateType type;

  final bool selected;

  final VoidCallback? onTap;

  @override
  State<CreateTypeCard> createState() =>
      _CreateTypeCardState();
}

class _CreateTypeCardState
    extends State<CreateTypeCard> {
  bool _hover = false;

  Color get accent =>
      widget.type.accentColor;

  @override
  Widget build(BuildContext context) {
    final type = widget.type;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },
      child: AnimatedScale(
        duration:
        const Duration(milliseconds: 220),
        scale: _hover ? 1.02 : 1,
        child: GlassCard(
          margin: EdgeInsets.zero,

          padding:
          const EdgeInsets.all(18),

          selected: widget.selected,

          accentColor: accent,

          variant: widget.selected
              ? GlassCardVariant.hero
              : GlassCardVariant.standard,

          level: widget.selected
              ? GlassLevel.hero
              : GlassLevel.normal,

          onTap: widget.onTap,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              _Header(
                type: type,
                accent: accent,
              ),

              const SizedBox(height: 20),

              _Icon(
                accent: accent,
                icon: type.icon,
              ),

              const Spacer(),

              _Title(
                title: type.title,
                accent: accent,
                selected: widget.selected,
              ),

              const SizedBox(height: 8),

              _Subtitle(
                subtitle: type.subtitle,
              ),

              if (type.featureCount != null)
                Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 16,
                  ),
                  child: _FeatureCount(
                    text:
                    type.featureCount!,
                    accent: accent,
                  ),
                ),

              const SizedBox(height: 16),

              _Footer(
                accent: accent,
                selected:
                widget.selected,
                difficulty:
                type.difficulty,
                estimatedMinutes:
                type.estimatedMinutes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.type,
    required this.accent,
  });

  final CreateType type;

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (type.recommended)
          _Badge(
            text: "Recommended",
            color: accent,
          ),

        if (type.badge != null &&
            !type.recommended)
          _Badge(
            text: type.badge!,
            color: accent,
          ),

        const Spacer(),

        if (type.isNew)
          const _SmallBadge(
            text: "NEW",
          ),

        if (type.isPremium)
          const Padding(
            padding:
            EdgeInsets.only(left: 6),
            child: Icon(
              Icons.workspace_premium,
              size: 18,
              color: Colors.amber,
            ),
          ),

        if (type.locked)
          const Padding(
            padding:
            EdgeInsets.only(left: 6),
            child: Icon(
              Icons.lock,
              size: 18,
              color: Colors.white70,
            ),
          ),

        if (type.isFavorite)
          const Padding(
            padding:
            EdgeInsets.only(left: 6),
            child: Icon(
              Icons.favorite,
              size: 18,
              color: Colors.redAccent,
            ),
          ),
      ],
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({
    required this.icon,
    required this.accent,
  });

  final IconData icon;

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: 66,
      height: 66,

      level: GlassLevel.strong,

      padding: EdgeInsets.zero,

      borderRadius: 20,

      gradient: LinearGradient(
        colors: [
          accent.withValues(alpha: .22),
          accent.withValues(alpha: .08),
        ],
      ),

      border: Border.all(
        color:
        accent.withValues(alpha: .25),
      ),

      child: Icon(
        icon,
        size: 32,
        color: accent,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    required this.selected,
    required this.accent,
  });

  final String title;

  final bool selected;

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color:
        selected ? accent : Colors.white,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.subtitle,
  });

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        height: 1.45,
        color:
        Colors.white.withValues(alpha: .62),
      ),
    );
  }
}
class _FeatureCount extends StatelessWidget {
  const _FeatureCount({
    required this.text,
    required this.accent,
  });

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.widgets_rounded,
          size: 15,
          color: accent,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.accent,
    required this.selected,
    required this.difficulty,
    required this.estimatedMinutes,
  });

  final Color accent;
  final bool selected;
  final CreateTypeDifficulty difficulty;
  final int estimatedMinutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DifficultyChip(
          difficulty: difficulty,
        ),

        const Spacer(),

        Icon(
          Icons.schedule_rounded,
          size: 15,
          color: Colors.white.withValues(alpha: .55),
        ),

        const SizedBox(width: 4),

        Text(
          "$estimatedMinutes min",
          style: TextStyle(
            color: Colors.white.withValues(alpha: .65),
            fontSize: 12,
          ),
        ),

        const SizedBox(width: 14),

        AnimatedContainer(
          duration: const Duration(
            milliseconds: 220,
          ),
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? accent
                : Colors.white.withValues(alpha: .18),
            boxShadow: selected
                ? [
              BoxShadow(
                color: accent.withValues(alpha: .45),
                blurRadius: 10,
              ),
            ]
                : null,
          ),
        ),

        const SizedBox(width: 10),

        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: selected
              ? accent
              : Colors.white.withValues(alpha: .45),
        ),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.difficulty,
  });

  final CreateTypeDifficulty difficulty;

  Color get color {
    switch (difficulty) {
      case CreateTypeDifficulty.beginner:
        return const Color(0xff24D39C);

      case CreateTypeDifficulty.intermediate:
        return const Color(0xffFFB547);

      case CreateTypeDifficulty.advanced:
        return const Color(0xffFF5D73);
    }
  }

  String get label {
    switch (difficulty) {
      case CreateTypeDifficulty.beginner:
        return "Beginner";

      case CreateTypeDifficulty.intermediate:
        return "Intermediate";

      case CreateTypeDifficulty.advanced:
        return "Advanced";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: color.withValues(alpha: .25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff24D39C),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}