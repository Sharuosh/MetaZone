import 'package:flutter/material.dart';

import '../glass/glass_button.dart';
import '../glass/glass_card.dart';

class TrendingTemplates extends StatelessWidget {
  const TrendingTemplates({
    super.key,
    required this.templates,
  });

  final List<TrendingTemplateItem> templates;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 390,

      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        physics:
        const BouncingScrollPhysics(),

        scrollDirection: Axis.horizontal,

        itemCount: templates.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 18),

        itemBuilder: (_, index) {
          return _TemplateCard(
            template: templates[index],
          );
        },
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({
    required this.template,
  });

  final TrendingTemplateItem template;

  @override
  State<_TemplateCard> createState() =>
      _TemplateCardState();
}

class _TemplateCardState
    extends State<_TemplateCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.template;

    return MouseRegion(
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: AnimatedScale(
        duration: const Duration(
          milliseconds: 220,
        ),
        scale: hover ? 1.03 : 1,
        child: SizedBox(
          width: 320,

          child: GlassCard(
            margin: EdgeInsets.zero,

            accentColor: t.color,

            variant: t.featured
                ? GlassCardVariant.hero
                : GlassCardVariant.standard,

            level: t.featured
                ? GlassLevel.hero
                : GlassLevel.normal,

            onTap: t.onTap,

            padding:
            const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.28,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (t.preview != null)
                          Image(
                            image: t.preview!,
                            fit: BoxFit.cover,
                          )
                        else
                          DecoratedBox(
                            decoration:
                            BoxDecoration(
                              gradient:
                              LinearGradient(
                                begin:
                                Alignment
                                    .topLeft,
                                end:
                                Alignment
                                    .bottomRight,
                                colors: [
                                  t.color,
                                  t.color
                                      .withValues(
                                    alpha: .45,
                                  ),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                t.icon,
                                size: 60,
                                color:
                                Colors.white,
                              ),
                            ),
                          ),

                        Positioned(
                          left: 14,
                          top: 14,
                          child: _CategoryChip(
                            text: t.featured
                                ? "Featured"
                                : t.category,
                            color: t.color,
                          ),
                        ),

                        if (t.trending)
                          const Positioned(
                            left: 14,
                            bottom: 14,
                            child:
                            _TrendingChip(),
                          ),

                        if (t.aiReady)
                          const Positioned(
                            right: 14,
                            bottom: 14,
                            child: _AIChip(),
                          ),

                        Positioned(
                          right: 14,
                          top: 14,
                          child: Row(
                            children: [
                              if (t.favorite)
                                const Icon(
                                  Icons
                                      .favorite,
                                  color:
                                  Colors.red,
                                ),

                              if (t.favorite)
                                const SizedBox(
                                  width: 8,
                                ),

                              if (t.premium)
                                const Icon(
                                  Icons
                                      .workspace_premium,
                                  color: Colors
                                      .amber,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  t.title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 19,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "by ${t.creator}",
                  style: TextStyle(
                    color: Colors.white
                        .withValues(
                      alpha: .60,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        Icons.download,
                        "${t.downloads}",
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        Icons.favorite,
                        "${t.likes}",
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        Icons.star,
                        t.rating
                            .toStringAsFixed(
                          1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        Icons.timer,
                        "${t.minutes}m",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    _DifficultyChip(
                      text:
                      t.difficulty,
                      color: t.color,
                    ),

                    const Spacer(),

                    Text(
                      "${t.usedBy} uses",
                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: .60,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                GlassButton(
                  hero: t.featured,
                  icon:
                  Icons.auto_fix_high,
                  text: "Use Template",
                  onPressed: t.onUse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
        border: Border.all(
          color: color.withValues(alpha: .30),
        ),
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

class _TrendingChip extends StatelessWidget {
  const _TrendingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: Colors.orange,
          ),
          SizedBox(width: 5),
          Text(
            "TRENDING",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIChip extends StatelessWidget {
  const _AIChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 13,
            color: Colors.amber,
          ),
          SizedBox(width: 5),
          Text(
            "AI",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
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
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      this.icon,
      this.value,
      );

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withValues(alpha: .65),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .70),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class TrendingTemplateItem {
  const TrendingTemplateItem({
    required this.title,
    required this.category,
    required this.rating,
    required this.downloads,

    this.creator = "MetaZone",

    this.likes = 0,
    this.usedBy = 0,
    this.minutes = 5,

    this.difficulty = "Easy",

    this.featured = false,
    this.premium = false,
    this.favorite = false,
    this.trending = false,
    this.aiReady = false,

    this.preview,

    this.icon = Icons.view_in_ar_rounded,

    this.color = const Color(0xff5B8CFF),

    this.onTap,
    this.onUse,
  });

  final String title;
  final String category;
  final double rating;
  final int downloads;

  final String creator;

  final int likes;
  final int usedBy;
  final int minutes;

  final String difficulty;

  final bool featured;
  final bool premium;
  final bool favorite;
  final bool trending;
  final bool aiReady;

  final ImageProvider? preview;

  final IconData icon;

  final Color color;

  final VoidCallback? onTap;
  final VoidCallback? onUse;

  TrendingTemplateItem copyWith({
    String? title,
    String? category,
    double? rating,
    int? downloads,
    String? creator,
    int? likes,
    int? usedBy,
    int? minutes,
    String? difficulty,
    bool? featured,
    bool? premium,
    bool? favorite,
    bool? trending,
    bool? aiReady,
    ImageProvider? preview,
    IconData? icon,
    Color? color,
    VoidCallback? onTap,
    VoidCallback? onUse,
  }) {
    return TrendingTemplateItem(
      title: title ?? this.title,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
      creator: creator ?? this.creator,
      likes: likes ?? this.likes,
      usedBy: usedBy ?? this.usedBy,
      minutes: minutes ?? this.minutes,
      difficulty: difficulty ?? this.difficulty,
      featured: featured ?? this.featured,
      premium: premium ?? this.premium,
      favorite: favorite ?? this.favorite,
      trending: trending ?? this.trending,
      aiReady: aiReady ?? this.aiReady,
      preview: preview ?? this.preview,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      onTap: onTap ?? this.onTap,
      onUse: onUse ?? this.onUse,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrendingTemplateItem &&
        other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}