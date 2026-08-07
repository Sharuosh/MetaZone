import 'package:flutter/material.dart';

import '../glass/glass_button.dart';
import '../glass/glass_card.dart';

enum HeroProjectStatus {
  draft,
  published,
  private,
  shared,
}

class HeroObjectCard extends StatefulWidget {
  const HeroObjectCard({
    super.key,
    required this.title,

    this.subtitle,

    this.thumbnail,

    this.progress = .65,

    this.lastEdited = "Today",

    this.lastSync = "Just now",

    this.objects = 0,

    this.views = 0,

    this.likes = 0,

    this.fileSize = "0 MB",

    this.collaborators = 1,

    this.favorite = false,

    this.live = false,

    this.aiOptimized = false,

    this.status =
        HeroProjectStatus.draft,

    this.accentColor =
    const Color(0xff5B8CFF),

    this.onContinue,
    this.onPreview,
    this.onDelete,
    this.onFavorite,
    this.onShare,
  });

  final String title;

  final String? subtitle;

  final ImageProvider? thumbnail;

  final double progress;

  final String lastEdited;

  final String lastSync;

  final int objects;

  final int collaborators;

  final int views;

  final int likes;

  final String fileSize;

  final HeroProjectStatus status;

  final bool favorite;

  final bool live;

  final bool aiOptimized;

  final Color accentColor;

  final VoidCallback? onContinue;

  final VoidCallback? onPreview;

  final VoidCallback? onDelete;

  final VoidCallback? onFavorite;

  final VoidCallback? onShare;

  @override
  State<HeroObjectCard> createState() =>
      _HeroObjectCardState();
}

class _HeroObjectCardState
    extends State<HeroObjectCard> {
  bool hover = false;

  Color get progressColor {
    if (widget.progress >= .85) {
      return const Color(0xff24D39C);
    }

    if (widget.progress >= .45) {
      return widget.accentColor;
    }

    return const Color(0xffFFB547);
  }

  Color get statusColor {
    switch (widget.status) {
      case HeroProjectStatus.draft:
        return const Color(0xffFFB547);

      case HeroProjectStatus.published:
        return const Color(0xff24D39C);

      case HeroProjectStatus.private:
        return const Color(0xffFF5C82);

      case HeroProjectStatus.shared:
        return const Color(0xff5B8CFF);
    }
  }

  String get statusText {
    switch (widget.status) {
      case HeroProjectStatus.draft:
        return "Draft";

      case HeroProjectStatus.published:
        return "Published";

      case HeroProjectStatus.private:
        return "Private";

      case HeroProjectStatus.shared:
        return "Shared";
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Duration(milliseconds: 250),
          scale: hover ? 1.01 : 1,
          child: GlassCard(
            variant: GlassCardVariant.hero,

            level: GlassLevel.hero,

            accentColor: widget.accentColor,

            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),

            padding:
            const EdgeInsets.all(20),

            child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
            ClipRRect(
            borderRadius:
            BorderRadius.circular(28),
            child: AspectRatio(
              aspectRatio: 16 / 9,

              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.thumbnail != null)
                    Image(
                      image:
                      widget.thumbnail!,
                      fit: BoxFit.cover,
                    )
                  else
                    DecoratedBox(
                      decoration:
                      BoxDecoration(
                        gradient:
                        LinearGradient(
                          begin: Alignment
                              .topLeft,
                          end: Alignment
                              .bottomRight,
                          colors: [
                            widget
                                .accentColor,
                            const Color(
                                0xff7A5FFF),
                          ],
                        ),
                      ),
                    ),

                  DecoratedBox(
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        begin:
                        Alignment
                            .topCenter,
                        end: Alignment
                            .bottomCenter,
                        colors: [
                          Colors
                              .transparent,
                          Colors.black
                              .withValues(
                              alpha:
                              .60),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 18,
                    left: 18,
                    child: _StatusChip(
                      text: statusText,
                      color: statusColor,
                    ),
                  ),

                  Positioned(
                    top: 18,
                    right: 18,
                    child: Row(
                      children: [
                        if (widget.live)
                          const _LiveBadge(),

                        if (widget.live)
                          const SizedBox(
                              width: 8),

                        if (widget.aiOptimized)
                          const _AIBadge(),

                        if (widget.aiOptimized)
                          const SizedBox(
                              width: 8),

                        IconButton(
                          onPressed:
                          widget
                              .onFavorite,
                          icon: Icon(
                            widget.favorite
                                ? Icons
                                .favorite
                                : Icons
                                .favorite_border,
                            color: Colors
                                .white,
                          ),
                        ),

                        IconButton(
                          onPressed:
                          widget
                              .onShare,
                          icon: const Icon(
                            Icons.share,
                            color: Colors
                                .white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          widget.title,
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize: 25,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),

                        if (widget.subtitle !=
                            null) ...[
                          const SizedBox(
                              height: 6),

                          Text(
                            widget.subtitle!,
                            style:
                            TextStyle(
                              color: Colors
                                  .white
                                  .withValues(
                                  alpha:
                                  .72),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _Info(
                  title: "Objects",
                  value:
                  "${widget.objects}",
                ),
              ),

              Expanded(
                child: _Info(
                  title: "Views",
                  value:
                  "${widget.views}",
                ),
              ),

              Expanded(
                child: _Info(
                  title: "Likes",
                  value:
                  "${widget.likes}",
                ),
              ),

              Expanded(
                child: _Info(
                  title: "Size",
                  value:
                  widget.fileSize,
                ),
              ),
            ],
          ),
                  const SizedBox(height: 24),

                  _ProgressSection(
                    progress: widget.progress,
                    color: progressColor,
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          hero: true,
                          icon: Icons.play_arrow_rounded,
                          text: "Continue",
                          onPressed: widget.onContinue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: GlassButton(
                          variant: GlassButtonVariant.secondary,
                          icon: Icons.visibility_outlined,
                          text: "Preview",
                          onPressed: widget.onPreview,
                        ),
                      ),

                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 12),

                        SizedBox(
                          width: 62,
                          child: GlassButton(
                            variant: GlassButtonVariant.danger,
                            icon: Icons.delete_outline,
                            text: "",
                            onPressed: widget.onDelete,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: .55),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "Edited ${widget.lastEdited}",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .60),
                          fontSize: 12,
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        Icons.cloud_done_rounded,
                        size: 16,
                        color: Colors.greenAccent,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        widget.lastSync,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .60),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
            ),
          ),
        ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            color: color,
            backgroundColor:
            Colors.white.withValues(alpha: .08),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "${(progress * 100).round()}% Complete",
          style: TextStyle(
            color: Colors.white.withValues(alpha: .65),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Colors.red,
          ),
          SizedBox(width: 6),
          Text(
            "LIVE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIBadge extends StatelessWidget {
  const _AIBadge();

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
            size: 14,
            color: Colors.amber,
          ),
          SizedBox(width: 6),
          Text(
            "AI",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .60),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}