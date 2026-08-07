import 'package:flutter/material.dart';

import '../glass/glass_button.dart';
import '../glass/glass_container.dart';

class CreateHeader extends StatelessWidget {
  const CreateHeader({
    super.key,

    this.userName = "Creator",

    this.avatar,

    this.notificationCount = 0,

    this.experiences = 0,

    this.templates = 0,

    this.onProfilePressed,
    this.onNotificationPressed,
    this.onAiPressed,
  });

  final String userName;

  final ImageProvider? avatar;

  final int notificationCount;

  final int experiences;

  final int templates;

  final VoidCallback? onProfilePressed;

  final VoidCallback? onNotificationPressed;

  final VoidCallback? onAiPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          0,
        ),
        child: GlassContainer(
          level: GlassLevel.hero,

          borderRadius: 30,

          padding: const EdgeInsets.all(22),

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: .10),
              Colors.white.withValues(alpha: .04),
            ],
          ),

          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onProfilePressed,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff6C63FF),
                            Color(0xff8F6CFF),
                          ],
                        ),
                        image: avatar != null
                            ? DecorationImage(
                          image: avatar!,
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: avatar == null
                          ? const Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: .60,
                            ),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Stack(
                    children: [
                      GlassContainer(
                        width: 48,
                        height: 48,
                        padding: EdgeInsets.zero,
                        borderRadius: 16,
                        onTap: onNotificationPressed,
                        child: const Center(
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      if (notificationCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xffFF5F7A),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              notificationCount > 9
                                  ? "9+"
                                  : "$notificationCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Create Your\nNext Experience",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Build immersive AR worlds using AI, templates and your own creativity.",
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: .65,
                            ),
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            _StatItem(
                              value: experiences.toString(),
                              label: "Experiences",
                            ),
                            const SizedBox(width: 18),
                            _StatItem(
                              value: templates.toString(),
                              label: "Templates",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  SizedBox(
                    width: 145,
                    child: GlassButton(
                      hero: true,
                      variant:
                      GlassButtonVariant.primary,
                      icon:
                      Icons.auto_awesome_rounded,
                      text: "AI Create",
                      onPressed: onAiPressed,
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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