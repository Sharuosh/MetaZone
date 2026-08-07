import 'package:flutter/material.dart';

import '../glass/glass_card.dart';
import '../glass/glass_container.dart';

class QuickCreateBar extends StatefulWidget {
  const QuickCreateBar({
    super.key,
    required this.items,
  });

  final List<QuickCreateItem> items;

  @override
  State<QuickCreateBar> createState() =>
      _QuickCreateBarState();
}

class _QuickCreateBarState
    extends State<QuickCreateBar> {
  final ScrollController _controller =
  ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 165,

      child: ListView.separated(
        controller: _controller,

        physics:
        const BouncingScrollPhysics(),

        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        scrollDirection: Axis.horizontal,

        itemCount: widget.items.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 16),

        itemBuilder: (context, index) {
          final item =
          widget.items[index];

          return _QuickCard(
            item: item,
          );
        },
      ),
    );
  }
}

class _QuickCard extends StatefulWidget {
  const _QuickCard({
    required this.item,
  });

  final QuickCreateItem item;

  @override
  State<_QuickCard> createState() =>
      _QuickCardState();
}

class _QuickCardState
    extends State<_QuickCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          hover = false;
        });
      },

      child: AnimatedScale(
        duration:
        const Duration(
          milliseconds: 220,
        ),

        scale: hover ? 1.03 : 1,

        child: SizedBox(
          width: 145,

          child: GlassCard(
            margin: EdgeInsets.zero,

            padding:
            const EdgeInsets.all(18),

            accentColor: item.color,

            selected:
            item.selected,

            disabled:
            item.locked,

            variant: item.hero
                ? GlassCardVariant.hero
                : GlassCardVariant.standard,

            level: item.hero
                ? GlassLevel.hero
                : GlassLevel.normal,

            onTap: item.locked
                ? null
                : item.onTap,

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    GlassContainer(
                      width: 52,
                      height: 52,

                      level:
                      GlassLevel.strong,

                      borderRadius: 18,

                      padding:
                      EdgeInsets.zero,

                      gradient:
                      LinearGradient(
                        colors: [
                          item.color
                              .withValues(
                              alpha:
                              .22),
                          item.color
                              .withValues(
                              alpha:
                              .08),
                        ],
                      ),

                      child: Icon(
                        item.icon,
                        color:
                        item.color,
                        size: 26,
                      ),
                    ),

                    const Spacer(),

                    if (item.favorite)
                      const Icon(
                        Icons.favorite,
                        size: 17,
                        color:
                        Colors.red,
                      ),

                    if (item.favorite)
                      const SizedBox(
                        width: 6,
                      ),

                    if (item.locked)
                      const Icon(
                        Icons.lock,
                        size: 17,
                        color: Colors
                            .white70,
                      ),
                  ],
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(
                  children: [
                    if (item.hero)
                      _Badge(
                        "Hero",
                        item.color,
                      ),

                    if (item.isNew)
                      const SizedBox(
                          width: 6),

                    if (item.isNew)
                      const _NewBadge(),

                    if (item.badge !=
                        null)
                      const SizedBox(
                          width: 6),

                    if (item.badge !=
                        null)
                      _Badge(
                        item.badge!,
                        item.color,
                      ),
                  ],
                ),

                const Spacer(),

                Text(
                  item.title,
                  maxLines: 2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 15,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                if (item.subtitle !=
                    null) ...[
                  const SizedBox(
                      height: 5),

                  Text(
                    item.subtitle!,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    TextStyle(
                      color: Colors
                          .white
                          .withValues(
                          alpha:
                          .60),
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    Icon(
                      Icons
                          .schedule_rounded,
                      size: 14,
                      color: Colors
                          .white
                          .withValues(
                          alpha:
                          .50),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      "${item.minutes} min",
                      style:
                      TextStyle(
                        color: Colors
                            .white
                            .withValues(
                            alpha:
                            .60),
                        fontSize: 11,
                      ),
                    ),

                    const Spacer(),

                    Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 14,
                      color: item
                          .selected
                          ? item.color
                          : Colors.white
                          .withValues(
                          alpha:
                          .45),
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
}
class _Badge extends StatelessWidget {
  const _Badge(
      this.text,
      this.color,
      );

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: .25),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff24D39C),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        "NEW",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class QuickCreateItem {
  const QuickCreateItem({
    required this.title,
    required this.icon,

    this.subtitle,

    this.badge,

    this.color = const Color(0xff5B8CFF),

    this.hero = false,

    this.selected = false,

    this.favorite = false,

    this.locked = false,

    this.isNew = false,

    this.minutes = 2,

    this.category = "General",

    this.onTap,
  });

  final String title;

  final IconData icon;

  final String? subtitle;

  final String? badge;

  final Color color;

  final bool hero;

  final bool selected;

  final bool favorite;

  final bool locked;

  final bool isNew;

  final int minutes;

  final String category;

  final VoidCallback? onTap;

  QuickCreateItem copyWith({
    String? title,
    IconData? icon,
    String? subtitle,
    String? badge,
    Color? color,
    bool? hero,
    bool? selected,
    bool? favorite,
    bool? locked,
    bool? isNew,
    int? minutes,
    String? category,
    VoidCallback? onTap,
  }) {
    return QuickCreateItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      subtitle: subtitle ?? this.subtitle,
      badge: badge ?? this.badge,
      color: color ?? this.color,
      hero: hero ?? this.hero,
      selected: selected ?? this.selected,
      favorite: favorite ?? this.favorite,
      locked: locked ?? this.locked,
      isNew: isNew ?? this.isNew,
      minutes: minutes ?? this.minutes,
      category: category ?? this.category,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuickCreateItem &&
        other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}