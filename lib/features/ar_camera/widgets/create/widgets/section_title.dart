import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,

    this.subtitle,

    this.icon,

    this.badge,

    this.action,

    this.actionText,

    this.onAction,

    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 10,
    ),

    this.accentColor,

    this.hero = false,

    this.showDivider = false,
  });

  final String title;

  final String? subtitle;

  final IconData? icon;

  final String? badge;

  final Widget? action;

  final String? actionText;

  final VoidCallback? onAction;

  final EdgeInsetsGeometry padding;

  final Color? accentColor;

  final bool hero;

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final accent =
        accentColor ??
            (hero
                ? const Color(0xff6C63FF)
                : const Color(0xff5B8CFF));

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: accent,
                  size: hero ? 24 : 22,
                ),
                const SizedBox(width: 12),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                              hero ? 24 : 22,
                              fontWeight:
                              FontWeight.w700,
                              letterSpacing: -.5,
                            ),
                          ),
                        ),

                        if (badge != null) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(
                                alpha: .16,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                50,
                              ),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white
                              .withValues(alpha: .60),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (action != null)
                action!
              else if (actionText != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Text(
                        actionText!,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (showDivider) ...[
            const SizedBox(height: 18),
            Divider(
              height: 1,
              color: Colors.white.withValues(
                alpha: .08,
              ),
            ),
          ],
        ],
      ),
    );
  }
}