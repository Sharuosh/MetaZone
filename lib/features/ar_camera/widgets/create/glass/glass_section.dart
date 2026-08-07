import 'package:flutter/material.dart';

import 'glass_card.dart';
import 'glass_container.dart';

enum GlassSectionVariant {
  standard,
  hero,
  accent,
}

class GlassSection extends StatelessWidget {
  const GlassSection({
    super.key,
    required this.title,
    required this.child,

    this.subtitle,

    this.icon,

    this.trailing,

    this.badge,

    this.margin =
    const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 10,
    ),

    this.padding =
    const EdgeInsets.all(22),

    this.spacing = 20,

    this.variant =
        GlassSectionVariant.standard,

    this.level = GlassLevel.normal,

    this.accentColor,

    this.showDivider = false,
  });

  final String title;

  final String? subtitle;

  final Widget child;

  final IconData? icon;

  final Widget? trailing;

  final String? badge;

  final EdgeInsetsGeometry margin;

  final EdgeInsetsGeometry padding;

  final double spacing;

  final GlassSectionVariant variant;

  final GlassLevel level;

  final Color? accentColor;

  final bool showDivider;

  Color? get accent {
    if (accentColor != null) {
      return accentColor;
    }

    switch (variant) {
      case GlassSectionVariant.standard:
        return null;

      case GlassSectionVariant.hero:
        return const Color(0xff6C63FF);

      case GlassSectionVariant.accent:
        return const Color(0xff5B8CFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: margin,

      padding: padding,

      level: level,

      variant: variant ==
          GlassSectionVariant.hero
          ? GlassCardVariant.hero
          : GlassCardVariant.standard,

      accentColor: accent,

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color:
                  accent ?? Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                              fontSize: 20,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(
                              width: 10),
                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration:
                            BoxDecoration(
                              color: (accent ??
                                  Colors
                                      .white)
                                  .withValues(
                                alpha: .16,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                100,
                              ),
                            ),
                            child: Text(
                              badge!,
                              style:
                              TextStyle(
                                color: accent ??
                                    Colors
                                        .white,
                                fontSize: 11,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(
                          height: 6),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white
                              .withValues(
                            alpha: .60,
                          ),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),

          if (showDivider) ...[
            const SizedBox(height: 18),
            Divider(
              color:
              Colors.white.withValues(
                alpha: .08,
              ),
              height: 1,
            ),
          ],

          SizedBox(height: spacing),

          child,
        ],
      ),
    );
  }
}