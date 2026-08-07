import 'package:flutter/material.dart';

import '../glass/glass_button.dart';
import '../glass/glass_card.dart';

class RecentProjects extends StatelessWidget {
  const RecentProjects({
    super.key,
    required this.projects,
  });

  final List<RecentProjectItem> projects;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 405,

      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        physics:
        const BouncingScrollPhysics(),

        scrollDirection: Axis.horizontal,

        itemCount: projects.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 18),

        itemBuilder: (_, index) {
          return _ProjectCard(
            project: projects[index],
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({
    required this.project,
  });

  final RecentProjectItem project;

  @override
  State<_ProjectCard> createState() =>
      _ProjectCardState();
}

class _ProjectCardState
    extends State<_ProjectCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return MouseRegion(
      onEnter: (_) =>
          setState(() => hover = true),

      onExit: (_) =>
          setState(() => hover = false),

      child: AnimatedScale(
        duration:
        const Duration(milliseconds: 220),

        scale: hover ? 1.02 : 1,

        child: SizedBox(
          width: 360,

          child: GlassCard(
            margin: EdgeInsets.zero,

            accentColor: p.color,

            selected: p.favorite,

            variant: p.hero
                ? GlassCardVariant.hero
                : GlassCardVariant.standard,

            level: p.hero
                ? GlassLevel.hero
                : GlassLevel.normal,

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
                    aspectRatio: 16 / 9,

                    child: Stack(
                      fit: StackFit.expand,

                      children: [
                        if (p.preview != null)
                          Image(
                            image: p.preview!,
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
                                  p.color,
                                  p.color
                                      .withValues(
                                    alpha: .45,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Positioned(
                          top: 14,
                          left: 14,
                          child: _StatusChip(
                            text: p.status,
                            color: p.color,
                          ),
                        ),

                        if (p.live)
                          const Positioned(
                            left: 14,
                            bottom: 14,
                            child: _LiveChip(),
                          ),

                        if (p.aiOptimized)
                          const Positioned(
                            right: 14,
                            bottom: 14,
                            child: _AIChip(),
                          ),

                        Positioned(
                          top: 14,
                          right: 14,
                          child: Row(
                            children: [
                              if (p.favorite)
                                const Icon(
                                  Icons.star,
                                  color:
                                  Colors.amber,
                                ),

                              if (p.favorite)
                                const SizedBox(
                                  width: 8,
                                ),

                              if (p.shared)
                                const Icon(
                                  Icons.groups,
                                  color: Colors
                                      .white,
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
                  p.title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                if (p.description != null) ...[
                  const SizedBox(height: 5),

                  Text(
                    p.description!,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white
                          .withValues(
                        alpha: .60,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _Info(
                        "Edited",
                        p.lastEdited,
                      ),
                    ),

                    Expanded(
                      child: _Info(
                        "Objects",
                        "${p.objects}",
                      ),
                    ),

                    Expanded(
                      child: _Info(
                        "Views",
                        "${p.views}",
                      ),
                    ),

                    Expanded(
                      child: _Info(
                        "Likes",
                        "${p.likes}",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _ProgressSection(
                  progress: p.progress,
                  color: p.color,
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        hero: true,
                        icon:
                        Icons.play_arrow,
                        text: "Continue",
                        onPressed:
                        p.onContinue,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: GlassButton(
                        variant:
                        GlassButtonVariant
                            .secondary,
                        icon:
                        Icons.visibility,
                        text: "Preview",
                        onPressed:
                        p.onPreview,
                      ),
                    ),

                    if (p.onDelete != null) ...[
                      const SizedBox(
                          width: 10),

                      SizedBox(
                        width: 60,
                        child: GlassButton(
                          variant:
                          GlassButtonVariant
                              .danger,
                          icon:
                          Icons.delete,
                          text: "",
                          onPressed:
                          p.onDelete,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 15,
                      color: Colors.green,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      p.lastSync,
                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: .60,
                        ),
                        fontSize: 12,
                      ),
                    ),

                    const Spacer(),

                    Icon(
                      Icons.people_alt,
                      size: 15,
                      color: Colors.white
                          .withValues(
                        alpha: .60,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      "${p.collaborators}",
                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: .60,
                        ),
                      ),
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
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.circular(40),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: color,
            backgroundColor:
            Colors.white.withValues(
              alpha: .08,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${(progress * 100).round()}% Complete",
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: .60,
            ),
            fontSize: 12,
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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(alpha: .18),
        borderRadius:
        BorderRadius.circular(50),
        border: Border.all(
          color:
          color.withValues(alpha: .30),
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

class _LiveChip extends StatelessWidget {
  const _LiveChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
        Colors.red.withValues(alpha: .20),
        borderRadius:
        BorderRadius.circular(40),
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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(
          alpha: .18,
        ),
        borderRadius:
        BorderRadius.circular(40),
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

class _Info extends StatelessWidget {
  const _Info(
      this.title,
      this.value,
      );

  final String title;
  final String value;

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
            fontWeight:
            FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: .60,
            ),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class RecentProjectItem {
  const RecentProjectItem({
    required this.title,
    required this.lastEdited,
    required this.progress,

    this.preview,
    this.description,

    this.color =
    const Color(0xff5B8CFF),

    this.status = "Draft",

    this.fileSize = "0 MB",

    this.objects = 0,

    this.views = 0,

    this.likes = 0,

    this.collaborators = 1,

    this.lastSync = "Synced",

    this.favorite = false,

    this.shared = false,

    this.live = false,

    this.aiOptimized = false,

    this.hero = false,

    this.onContinue,
    this.onPreview,
    this.onDelete,
  });

  final String title;
  final String? description;
  final String lastEdited;
  final double progress;

  final ImageProvider? preview;

  final Color color;

  final String status;

  final String fileSize;

  final int objects;

  final int views;

  final int likes;

  final int collaborators;

  final String lastSync;

  final bool favorite;

  final bool shared;

  final bool live;

  final bool aiOptimized;

  final bool hero;

  final VoidCallback? onContinue;

  final VoidCallback? onPreview;

  final VoidCallback? onDelete;

  RecentProjectItem copyWith({
    String? title,
    String? description,
    String? lastEdited,
    double? progress,
    ImageProvider? preview,
    Color? color,
    String? status,
    String? fileSize,
    int? objects,
    int? views,
    int? likes,
    int? collaborators,
    String? lastSync,
    bool? favorite,
    bool? shared,
    bool? live,
    bool? aiOptimized,
    bool? hero,
    VoidCallback? onContinue,
    VoidCallback? onPreview,
    VoidCallback? onDelete,
  }) {
    return RecentProjectItem(
      title: title ?? this.title,
      description:
      description ?? this.description,
      lastEdited:
      lastEdited ?? this.lastEdited,
      progress: progress ?? this.progress,
      preview: preview ?? this.preview,
      color: color ?? this.color,
      status: status ?? this.status,
      fileSize: fileSize ?? this.fileSize,
      objects: objects ?? this.objects,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      collaborators:
      collaborators ??
          this.collaborators,
      lastSync:
      lastSync ?? this.lastSync,
      favorite:
      favorite ?? this.favorite,
      shared: shared ?? this.shared,
      live: live ?? this.live,
      aiOptimized:
      aiOptimized ??
          this.aiOptimized,
      hero: hero ?? this.hero,
      onContinue:
      onContinue ?? this.onContinue,
      onPreview:
      onPreview ?? this.onPreview,
      onDelete:
      onDelete ?? this.onDelete,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecentProjectItem &&
          other.title == title;

  @override
  int get hashCode => title.hashCode;
}
